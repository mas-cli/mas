//
// Uninstall.swift
// mas
//
// Created by Ben Chatelain on 2018-12-27.
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import ScriptingBridge

extension MAS {
	/// Uninstalls apps installed from the Mac App Store.
	struct Uninstall: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Uninstall apps installed from the Mac App Store"
		)

		/// Flag indicating that removal shouldn't be performed.
		@Flag(help: "Perform dry run")
		var dryRun = false
		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async throws {
			try run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			guard NSUserName() == "root" else {
				throw MASError.macOSUserMustBeRoot
			}

			let uninstallingAppSet = try uninstallingAppSet(fromInstalledApps: installedApps)
			guard !uninstallingAppSet.isEmpty else {
				return
			}

			if dryRun {
				for installedApp in uninstallingAppSet {
					printNotice("'", installedApp.name, "' '", installedApp.path, "'", separator: "")
				}
				printNotice("(not removed, dry run)")
			} else {
				try uninstallApps(atPaths: uninstallingAppSet.map(\.path))
			}
		}

		private func uninstallingAppSet(fromInstalledApps installedApps: [InstalledApp]) throws -> Set<InstalledApp> {
			guard let sudoGroupName = ProcessInfo.processInfo.sudoGroupName else {
				throw MASError.runtimeError("Failed to determine the original group name")
			}
			guard let sudoGID = ProcessInfo.processInfo.sudoGID else {
				throw MASError.runtimeError("Failed to get original gid")
			}
			guard setegid(sudoGID) == 0 else {
				throw MASError.runtimeError("Failed to switch effective group from 'wheel' to '\(sudoGroupName)'")
			}
			defer {
				if setegid(0) != 0 {
					printWarning("Failed to revert effective group from '", sudoGroupName, "' back to 'wheel'", separator: "")
				}
			}

			guard let sudoUserName = ProcessInfo.processInfo.sudoUserName else {
				throw MASError.runtimeError("Failed to determine the original user name")
			}
			guard let sudoUID = ProcessInfo.processInfo.sudoUID else {
				throw MASError.runtimeError("Failed to get original uid")
			}
			guard seteuid(sudoUID) == 0 else {
				throw MASError.runtimeError("Failed to switch effective user from 'root' to '\(sudoUserName)'")
			}
			defer {
				if seteuid(0) != 0 {
					printWarning("Failed to revert effective user from '", sudoUserName, "' back to 'root'", separator: "")
				}
			}

			var uninstallingAppSet = Set<InstalledApp>()
			for appID in appIDsOptionGroup.appIDs {
				let apps = installedApps.filter { $0.id == appID }
				apps.isEmpty // swiftformat:disable:next indent
				? printError(appID.notInstalledMessage)
				: uninstallingAppSet.formUnion(apps)
			}
			return uninstallingAppSet
		}
	}
}

/// Uninstalls all apps located at any of the elements of `appPaths`.
///
/// - Parameter appPaths: Paths to apps to be uninstalled.
/// - Throws: An `Error` if any problem occurs.
private func uninstallApps(atPaths appPaths: [String]) throws {
	let finderItems = try finderItems()

	guard let uid = ProcessInfo.processInfo.sudoUID else {
		throw MASError.runtimeError("Failed to get original uid")
	}
	guard let gid = ProcessInfo.processInfo.sudoGID else {
		throw MASError.runtimeError("Failed to get original gid")
	}

	for appPath in appPaths {
		guard let (appUID, appGID) = uidAndGid(forPath: appPath) else {
			continue
		}
		guard chown(appPath, uid, gid) == 0 else {
			printError("Failed to change ownership of '", appPath, "' to uid ", uid, " & gid ", gid, separator: "")
			continue
		}
		var chownPath = appPath
		defer {
			if chown(chownPath, appUID, appGID) != 0 {
				printWarning(
					"Failed to revert ownership of '",
					chownPath,
					"' back to uid ",
					appUID,
					" & gid ",
					appGID,
					separator: ""
				)
			}
		}

		let object = finderItems.object(atLocation: URL(fileURLWithPath: appPath))
		guard let item = object as? FinderItem else {
			printError(
				"""
				Failed to obtain Finder access: finderItems.object(atLocation: URL(fileURLWithPath:\
				 \"\(appPath)\") is a \(type(of: object)) that does not conform to FinderItem
				"""
			)
			continue
		}

		guard let delete = item.delete else {
			printError("Failed to obtain Finder access: FinderItem.delete does not exist")
			continue
		}

		guard let deletedURLString = (delete() as FinderItem).URL else {
			printError(
				"""
				Failed to revert ownership of deleted '\(appPath)' back to uid \(appUID) & gid \(appGID):\
				 delete result did not have a URL
				"""
			)
			continue
		}

		guard let deletedURL = URL(string: deletedURLString) else {
			printError(
				"""
				Failed to revert ownership of deleted '\(appPath)' back to uid \(appUID) & gid \(appGID):\
				 delete result URL is invalid: \(deletedURLString)
				"""
			)
			continue
		}

		chownPath = deletedURL.path
		printInfo("Deleted '", appPath, "' to '", chownPath, "'", separator: "")
	}
}

private func finderItems() throws -> SBElementArray {
	guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as FinderApplication? else {
		throw MASError.runtimeError("Failed to obtain Finder access: com.apple.finder does not exist")
	}
	guard let items = finder.items else {
		throw MASError.runtimeError("Failed to obtain Finder access: finder.items does not exist")
	}
	return items()
}

private func uidAndGid(forPath path: String) -> (uid_t, gid_t)? {
	do {
		let attributes = try FileManager.default.attributesOfItem(atPath: path)
		guard let uid = attributes[.ownerAccountID] as? uid_t else {
			printError("Failed to determine uid of", path)
			return nil
		}
		guard let gid = attributes[.groupOwnerAccountID] as? gid_t else {
			printError("Failed to determine gid of", path)
			return nil
		}
		return (uid, gid)
	} catch {
		printError(error)
		return nil
	}
}
