//
// Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Darwin
private import Foundation
private import OrderedCollections
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
		var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try run(installedApps: try await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			try MAS.run { try run(printer: $0, installedApps: installedApps) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp]) throws {
			guard NSUserName() == "root" else {
				throw MASError.runtimeError("Apps installed from the Mac App Store require root permission to remove")
			}

			let uninstallingAppPaths = try uninstallingAppPaths(fromInstalledApps: installedApps, printer: printer)
			guard !uninstallingAppPaths.isEmpty else {
				return
			}
			guard !dryRun else {
				printer.notice("Dry run. A wet run would uninstall:\n")
				for uninstallingAppPath in uninstallingAppPaths {
					printer.info(uninstallingAppPath)
				}
				return
			}

			try uninstallApps(atPaths: uninstallingAppPaths, printer: printer)
		}

		private func uninstallingAppPaths(
			fromInstalledApps installedApps: [InstalledApp],
			printer: Printer
		) throws -> [String] {
			guard let sudoGroupName = ProcessInfo.processInfo.sudoGroupName else {
				throw MASError.runtimeError("Failed to get original group name")
			}
			guard let sudoGID = ProcessInfo.processInfo.sudoGID else {
				throw MASError.runtimeError("Failed to get original gid")
			}
			guard setegid(sudoGID) == 0 else {
				throw MASError.runtimeError("Failed to switch effective group from 'wheel' to '\(sudoGroupName)'")
			}

			defer {
				if setegid(0) != 0 {
					printer.warning("Failed to revert effective group from '", sudoGroupName, "' back to 'wheel'", separator: "")
				}
			}

			guard let sudoUserName = ProcessInfo.processInfo.sudoUserName else {
				throw MASError.runtimeError("Failed to get original user name")
			}
			guard let sudoUID = ProcessInfo.processInfo.sudoUID else {
				throw MASError.runtimeError("Failed to get original uid")
			}
			guard seteuid(sudoUID) == 0 else {
				throw MASError.runtimeError("Failed to switch effective user from 'root' to '\(sudoUserName)'")
			}

			defer {
				if seteuid(0) != 0 {
					printer.warning("Failed to revert effective user from '", sudoUserName, "' back to 'root'", separator: "")
				}
			}

			var uninstallingAppPathSet = OrderedSet<String>()
			for appID in requiredAppIDsOptionGroup.appIDs {
				let installedAppPaths = installedApps.filter { $0.matches(appID) }.map(\.path)
				installedAppPaths.isEmpty
				? printer.error(appID.notInstalledMessage) // swiftformat:disable:this indent
				: uninstallingAppPathSet.formUnion(installedAppPaths)
			}
			return Array(uninstallingAppPathSet)
		}
	}
}

/// Uninstalls all apps located at any of the elements of `appPaths`.
///
/// - Parameters:
///   - appPaths: Paths to apps to be uninstalled.
///   - printer: `Printer`.
/// - Throws: An `Error` if any problem occurs.
private func uninstallApps(atPaths appPaths: [String], printer: Printer) throws {
	guard let uid = ProcessInfo.processInfo.sudoUID else {
		throw MASError.runtimeError("Failed to get original uid")
	}
	guard let gid = ProcessInfo.processInfo.sudoGID else {
		throw MASError.runtimeError("Failed to get original gid")
	}
	guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as (any FinderApplication)? else {
		throw MASError.runtimeError("Failed to obtain Finder access: com.apple.finder does not exist")
	}
	guard let items = finder.items else {
		throw MASError.runtimeError("Failed to obtain Finder access: finder.items does not exist")
	}

	let fileManager = FileManager.default
	for appPath in appPaths {
		let attributes = try fileManager.attributesOfItem(atPath: appPath)
		guard let appUID = attributes[.ownerAccountID] as? uid_t else {
			printer.error("Failed to get uid of", appPath)
			continue
		}
		guard let appGID = attributes[.groupOwnerAccountID] as? gid_t else {
			printer.error("Failed to get gid of", appPath)
			continue
		}
		guard chown(appPath, uid, gid) == 0 else {
			printer.error("Failed to change ownership of '", appPath, "' to uid ", uid, " & gid ", gid, separator: "")
			continue
		}

		var chownPath = appPath
		defer {
			if chown(chownPath, appUID, appGID) != 0 {
				printer.warning(
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

		let object = items().object(atLocation: URL(fileURLWithPath: appPath))
		guard let item = object as? any FinderItem else {
			printer.error(
				"""
				Failed to obtain Finder access: finder.items().object(atLocation: URL(fileURLWithPath:\
				 \"\(appPath)\") is a \(type(of: object)) that does not conform to FinderItem
				"""
			)
			continue
		}
		guard let delete = item.delete else {
			printer.error("Failed to obtain Finder access: FinderItem.delete does not exist")
			continue
		}
		guard let deletedURLString = (delete() as any FinderItem).URL else {
			printer.error(
				"""
				Failed to revert ownership of deleted '\(appPath)' back to uid \(appUID) & gid \(appGID):\
				 delete result did not have a URL
				"""
			)
			continue
		}
		guard let deletedURL = URL(string: deletedURLString) else {
			printer.error(
				"""
				Failed to revert ownership of deleted '\(appPath)' back to uid \(appUID) & gid \(appGID):\
				 delete result URL is invalid: \(deletedURLString)
				"""
			)
			continue
		}

		chownPath = deletedURL.path
		printer.info("Deleted '", appPath, "' to '", chownPath, "'", separator: "")
	}
}
