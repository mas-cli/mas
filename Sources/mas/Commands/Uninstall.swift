//
// Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import ScriptingBridge

extension MAS {
	/// Uninstalls apps installed from the Mac App Store by App ID.
	///
	/// This command removes apps previously installed via `mas install`,
	/// identified by their App Store ID. It uses macOS’s Finder infrastructure
	/// to safely move the app to the Trash.
	///
	/// > Important:
	/// > You must run this command with root privileges (via `sudo`).
	///
	/// > Tip:
	/// > Use `--dry-run` to preview which apps would be removed, without deleting anything.
	///
	/// Example:
	/// ```bash
	/// sudo mas uninstall 497799835
	/// ```
	///
	/// Dry run:
	/// ```bash
	/// mas uninstall 497799835 --dry-run
	/// ```
	///
	/// > Note:
	/// > This command only affects apps listed by `mas list`.
	/// 
	/// > Important:
	/// > This command relies on macOS Spotlight indexing to detect installed apps.
	/// > If some apps do not appear as expected, you may need to rebuild the metadata index:
	/// > ```bash
	/// > sudo mdutil -Eai on
	/// > ```
	/// > For details, see the [README Troubleshooting Section](https://github.com/mas-cli/mas#troubleshooting).

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
			try mas.run { try run(printer: $0, installedApps: installedApps) }
		}

		private func run(printer: Printer, installedApps: [InstalledApp]) throws {
			guard NSUserName() == "root" else {
				throw MASError.runtimeError("Apps installed from the Mac App Store require root permission to remove")
			}

			let uninstallingAppSet = try uninstallingAppSet(fromInstalledApps: installedApps, printer: printer)
			guard !uninstallingAppSet.isEmpty else {
				return
			}

			if dryRun {
				for installedApp in uninstallingAppSet {
					printer.notice("'", installedApp.name, "' '", installedApp.path, "'", separator: "")
				}
				printer.notice("(not removed, dry run)")
			} else {
				try uninstallApps(atPaths: uninstallingAppSet.map(\.path), printer: printer)
			}
		}

		private func uninstallingAppSet(
			fromInstalledApps installedApps: [InstalledApp],
			printer: Printer
		) throws -> Set<InstalledApp> {
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

			var uninstallingAppSet = Set<InstalledApp>()
			for appID in appIDsOptionGroup.appIDs {
				let apps = installedApps.filter { $0.id == appID }
				apps.isEmpty // swiftformat:disable:next indent
				? printer.error(appID.notInstalledMessage)
				: uninstallingAppSet.formUnion(apps)
			}
			return uninstallingAppSet
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
	let finderItems = try finderItems()

	guard let uid = ProcessInfo.processInfo.sudoUID else {
		throw MASError.runtimeError("Failed to get original uid")
	}
	guard let gid = ProcessInfo.processInfo.sudoGID else {
		throw MASError.runtimeError("Failed to get original gid")
	}

	for appPath in appPaths {
		let attributes = try FileManager.default.attributesOfItem(atPath: appPath)
		guard let appUID = attributes[.ownerAccountID] as? uid_t else {
			printer.error("Failed to determine uid of", appPath)
			continue
		}
		guard let appGID = attributes[.groupOwnerAccountID] as? gid_t else {
			printer.error("Failed to determine gid of", appPath)
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

		let object = finderItems.object(atLocation: URL(fileURLWithPath: appPath))
		guard let item = object as? FinderItem else {
			printer.error(
				"""
				Failed to obtain Finder access: finderItems.object(atLocation: URL(fileURLWithPath:\
				 \"\(appPath)\") is a \(type(of: object)) that does not conform to FinderItem
				"""
			)
			continue
		}
		guard let delete = item.delete else {
			printer.error("Failed to obtain Finder access: FinderItem.delete does not exist")
			continue
		}
		guard let deletedURLString = (delete() as FinderItem).URL else {
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

private func finderItems() throws -> SBElementArray {
	guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as FinderApplication? else {
		throw MASError.runtimeError("Failed to obtain Finder access: com.apple.finder does not exist")
	}
	guard let items = finder.items else {
		throw MASError.runtimeError("Failed to obtain Finder access: finder.items does not exist")
	}

	return items()
}
