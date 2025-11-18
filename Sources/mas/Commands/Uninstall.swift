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
	struct Uninstall: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Uninstall apps installed from the Mac App Store"
		)

		/// Flag indicating that removal shouldn't be performed.
		@Flag(help: "Perform dry run")
		private var dryRun = false
		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async {
			do {
				try run(installedApps: try await installedApps)
			} catch {
				printer.error(error: error)
			}
		}

		func run(installedApps: [InstalledApp]) throws {
			guard NSUserName() == "root" else {
				throw MASError.runtimeError("Apps installed from the Mac App Store require root permission to uninstall")
			}

			let uninstallingAppPaths = uninstallingAppPaths(from: installedApps)
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

			try uninstallApps(atPaths: uninstallingAppPaths)
		}

		private func uninstallingAppPaths(from installedApps: [InstalledApp]) -> [String] {
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
/// - Parameter: appPaths: Paths to apps to be uninstalled.
/// - Throws: An `Error` if any problem occurs.
private func uninstallApps(atPaths appPaths: [String]) throws {
	guard let uid = ProcessInfo.processInfo.sudoUID else {
		throw MASError.runtimeError("Failed to get original uid")
	}
	guard let gid = ProcessInfo.processInfo.sudoGID else {
		throw MASError.runtimeError("Failed to get original gid")
	}
	guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as (any FinderApplication)? else {
		throw MASError.runtimeError("Failed to obtain Finder access: bundle com.apple.finder does not exist")
	}
	guard let items = finder.items else {
		throw MASError.runtimeError("Failed to obtain Finder access: FinderApplication.items() does not exist")
	}

	let fileManager = FileManager.default
	for appPath in appPaths {
		let attributes = try fileManager.attributesOfItem(atPath: appPath)
		guard let appUID = attributes[.ownerAccountID] as? uid_t else {
			MAS.printer.error("Failed to get uid of", appPath)
			continue
		}
		guard let appGID = attributes[.groupOwnerAccountID] as? gid_t else {
			MAS.printer.error("Failed to get gid of", appPath)
			continue
		}
		guard chown(appPath, uid, gid) == 0 else {
			MAS.printer.error("Failed to change ownership of", appPath.quoted, "to uid", uid, "& gid", gid)
			continue
		}

		var chownPath = appPath
		defer {
			if chown(chownPath, appUID, appGID) != 0 {
				MAS.printer.warning("Failed to revert ownership of", chownPath.quoted, "back to uid", appUID, "& gid", appGID)
			}
		}

		let object = items().object(atLocation: URL(fileURLWithPath: appPath))
		guard let item = object as? any FinderItem else {
			MAS.printer.error(
				"""
				Failed to obtain Finder access: FinderApplication.items().object(atLocation: URL(fileURLWithPath:\
				 \"\(appPath)\") is a \(type(of: object)) that does not conform to FinderItem
				"""
			)
			continue
		}
		guard let delete = item.delete else {
			MAS.printer.error("Failed to obtain Finder access: FinderItem.delete does not exist")
			continue
		}
		guard let deletedURLString = (delete() as any FinderItem).URL else {
			MAS.printer.error(
				"""
				Failed to revert ownership of uninstalled \(appPath.quoted) back to uid \(appUID) & gid \(appGID):\
				 delete result did not have a URL
				"""
			)
			continue
		}
		guard let deletedURL = URL(string: deletedURLString) else {
			MAS.printer.error(
				"""
				Failed to revert ownership of uninstalled \(appPath.quoted) back to uid \(appUID) & gid \(appGID):\
				 delete result URL is invalid: \(deletedURLString)
				"""
			)
			continue
		}

		chownPath = deletedURL.path
		MAS.printer.info("Uninstalled", appPath.quoted, "to", chownPath.quoted)
	}
}
