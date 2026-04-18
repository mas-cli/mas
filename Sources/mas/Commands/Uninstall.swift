//
// Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation
private import OrderedCollections

extension MAS {
	/// Uninstalls apps installed from the App Store.
	struct Uninstall: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Uninstall apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage(),
		)

		@Flag(name: .customLong("dry-run"), help: "Perform dry run")
		private var isPerformingDryRun = false
		@Flag(name: .customLong("all"), help: "Uninstall all App Store apps")
		private var isUninstallingAll = false
		@OptionGroup
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func validate() throws(ValidationError) {
			if isUninstallingAll != installedAppIDsOptionGroup.appIDs.isEmpty {
				throw .init(
					isUninstallingAll
					? "Cannot specify both --all & app IDs" // swiftformat:disable:this indent
					: "Must specify either --all or at least one app ID",
				)
			}
		}

		func run() async throws {
			try run(installedApps: try await installedApps)
		}

		private func run(installedApps: [InstalledApp]) throws {
			let uninstallingADAMIDOrderedByPath = (
				isUninstallingAll ? installedApps.map { .bundleID($0.bundleID) } : installedAppIDsOptionGroup.appIDs,
			)
			.reduce(into: OrderedDictionary<String, String>()) { uninstallingADAMIDOrderedByPath, appID in
				let uninstallingApps = installedApps.filter { $0.matches(appID) }
				guard !uninstallingApps.isEmpty else {
					printer.error(appID.notInstalledMessage)
					return
				}

				for uninstallingApp in uninstallingApps {
					uninstallingADAMIDOrderedByPath[uninstallingApp.path] = .init(uninstallingApp.adamID)
				}
			}
			guard !uninstallingADAMIDOrderedByPath.isEmpty else {
				return
			}
			guard !isPerformingDryRun else {
				printer.notice("Dry run. A wet run would uninstall:\n")
				for appPath in uninstallingADAMIDOrderedByPath.keys {
					printer.info(appPath)
				}
				return
			}
			guard getuid() == 0 else {
				try sudo(MAS._commandName, args: [Self._commandName] + uninstallingADAMIDOrderedByPath.values)
				return
			}

			let processInfo = ProcessInfo.processInfo
			let uid = try processInfo.sudoUID
			let gid = try processInfo.sudoGID
			let fileManager = FileManager.default
			for appPath in uninstallingADAMIDOrderedByPath.keys {
				let attributes = try fileManager.attributesOfItem(atPath: appPath)
				guard let appUID = attributes[.ownerAccountID] as? uid_t else {
					printer.error("Failed to get uid of", appPath)
					continue
				}
				guard let appGID = attributes[.groupOwnerAccountID] as? gid_t else {
					printer.error("Failed to get gid of", appPath)
					continue
				}

				do {
					try mas.run(asEffectiveUID: 0, andEffectiveGID: 0) {
						try fileManager.setAttributes([.ownerAccountID: uid, .groupOwnerAccountID: gid], ofItemAtPath: appPath)
					}
				} catch {
					printer.error("Failed to change ownership of", appPath.quoted, "to uid", uid, "& gid", gid, error: error)
					continue
				}

				var chownPath = appPath
				defer {
					do {
						try mas.run(asEffectiveUID: 0, andEffectiveGID: 0) {
							try fileManager.setAttributes(
								[.ownerAccountID: appUID, .groupOwnerAccountID: appGID],
								ofItemAtPath: chownPath,
							)
						}
					} catch {
						printer.warning(
							"Failed to revert ownership of",
							chownPath.quoted,
							"back to uid",
							appUID,
							"& gid",
							appGID,
							error: error,
						)
					}
				}

				var uninstalledAppNSURL = NSURL?.none // swiftlint:disable:this legacy_objc_type
				try unsafe fileManager.trashItem(
					at: .init(filePath: appPath, directoryHint: .isDirectory),
					resultingItemURL: &uninstalledAppNSURL,
				)
				guard let uninstalledAppPath = uninstalledAppNSURL?.path else {
					printer.error( // editorconfig-checker-disable
						"""
						Failed to revert ownership of uninstalled \(appPath.quoted) back to uid \(appUID) & gid \(appGID):\
						 failed to get uninstalled app URL
						""", // editorconfig-checker-enable
					)
					continue
				}

				chownPath = uninstalledAppPath
				printer.info("Uninstalled", appPath.quoted, "to", chownPath.quoted)
			}
		}
	}
}
