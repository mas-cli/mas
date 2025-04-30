//
//  Uninstall.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import ScriptingBridge

extension MAS {
	/// Command which uninstalls apps managed by the Mac App Store.
	struct Uninstall: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Uninstall app installed from the Mac App Store"
		)

		/// Flag indicating that removal shouldn't be performed.
		@Flag(help: "Perform dry run")
		var dryRun = false
		@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
		var appIDs: [AppID]

		/// Runs the uninstall command.
		func run() async throws {
			try run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			guard NSUserName() == "root" else {
				throw MASError.macOSUserMustBeRoot
			}

			guard let username = ProcessInfo.processInfo.sudoUsername else {
				throw MASError.runtimeError("Could not determine the original username")
			}

			guard
				let uid = ProcessInfo.processInfo.sudoUID,
				seteuid(uid) == 0
			else {
				throw MASError.runtimeError("Failed to switch effective user from 'root' to '\(username)'")
			}

			let installedApps = installedApps.filter { appIDs.contains($0.id) }
			guard !installedApps.isEmpty else {
				throw MASError.notInstalled(appIDs: appIDs)
			}

			if dryRun {
				for installedApp in installedApps {
					printInfo("'", installedApp.name, "' '", installedApp.path, "'", separator: "")
				}
				printInfo("(not removed, dry run)")
			} else {
				guard seteuid(0) == 0 else {
					throw MASError.runtimeError("Failed to revert effective user from '\(username)' back to 'root'")
				}

				try uninstallApps(atPaths: installedApps.map(\.path))
			}
		}
	}
}

/// Uninstalls all apps located at any of the elements of `appPaths`.
///
/// - Parameter appPaths: Paths to apps to be uninstalled.
/// - Throws: An `Error` if any problem occurs.
private func uninstallApps(atPaths appPaths: [String]) throws {
	try delete(pathsFromOwnerIDsByPath: try chown(paths: appPaths))
}

private func chown(paths: [String]) throws -> [String: (uid_t, gid_t)] {
	guard let sudoUID = ProcessInfo.processInfo.sudoUID else {
		throw MASError.runtimeError("Failed to get original uid")
	}

	guard let sudoGID = ProcessInfo.processInfo.sudoGID else {
		throw MASError.runtimeError("Failed to get original gid")
	}

	let ownerIDsByPath = try paths.reduce(into: [String: (uid_t, gid_t)]()) { dict, path in
		dict[path] = try getOwnerAndGroupOfItem(atPath: path)
	}

	var chownedIDsByPath = [String: (uid_t, gid_t)]()
	for (path, ownerIDs) in ownerIDsByPath {
		guard chown(path, sudoUID, sudoGID) == 0 else {
			for (chownedPath, chownedIDs) in chownedIDsByPath
			where chown(chownedPath, chownedIDs.0, chownedIDs.1) != 0 {
				printError(
					"Failed to revert ownership of '",
					path,
					"' back to uid ",
					chownedIDs.0,
					" & gid ",
					chownedIDs.1,
					separator: ""
				)
			}
			throw MASError.runtimeError("Failed to change ownership of '\(path)' to uid \(sudoUID) & gid \(sudoGID)")
		}

		chownedIDsByPath[path] = ownerIDs
	}

	return ownerIDsByPath
}

private func getOwnerAndGroupOfItem(atPath path: String) throws -> (uid_t, gid_t) {
	do {
		let attributes = try FileManager.default.attributesOfItem(atPath: path)
		guard
			let uid = attributes[.ownerAccountID] as? uid_t,
			let gid = attributes[.groupOwnerAccountID] as? gid_t
		else {
			throw MASError.runtimeError("Failed to determine running user's uid & gid")
		}
		return (uid, gid)
	}
}

private func delete(pathsFromOwnerIDsByPath ownerIDsByPath: [String: (uid_t, gid_t)]) throws {
	guard let finder = SBApplication(bundleIdentifier: "com.apple.finder") as FinderApplication? else {
		throw MASError.runtimeError("Failed to obtain Finder access: com.apple.finder does not exist")
	}

	guard let items = finder.items else {
		throw MASError.runtimeError("Failed to obtain Finder access: finder.items does not exist")
	}

	for (path, ownerIDs) in ownerIDsByPath {
		let object = items().object(atLocation: URL(fileURLWithPath: path))

		guard let item = object as? FinderItem else {
			throw MASError.runtimeError(
				"""
				Failed to obtain Finder access: finder.items().object(atLocation: URL(fileURLWithPath:\
				 \"\(path)\") is a '\(type(of: object))' that does not conform to 'FinderItem'
				"""
			)
		}

		guard let delete = item.delete else {
			throw MASError.runtimeError("Failed to obtain Finder access: FinderItem.delete does not exist")
		}

		let uid = ownerIDs.0
		let gid = ownerIDs.1
		guard let deletedURLString = (delete() as FinderItem).URL else {
			throw MASError.runtimeError(
				"""
				Failed to revert ownership of deleted '\(path)' back to uid \(uid) & gid \(gid):\
				 delete result did not have a URL
				"""
			)
		}

		guard let deletedURL = URL(string: deletedURLString) else {
			throw MASError.runtimeError(
				"""
				Failed to revert ownership of deleted '\(path)' back to uid \(uid) & gid \(gid):\
				 delete result URL is invalid: \(deletedURLString)
				"""
			)
		}

		let deletedPath = deletedURL.path
		print("Deleted '", path, "' to '", deletedPath, "'", separator: "")
		guard chown(deletedPath, uid, gid) == 0 else {
			throw MASError.runtimeError(
				"Failed to revert ownership of deleted '\(deletedPath)' back to uid \(uid) & gid \(gid)"
			)
		}
	}
}
