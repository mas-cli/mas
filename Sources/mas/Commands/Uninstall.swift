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
	struct Uninstall: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Uninstall apps installed from the App Store",
			discussion: requiresRootPrivilegesMessage()
		)

		/// Flag indicating that uninstall shouldn't be performed.
		@Flag(help: "Perform dry run")
		private var dryRun = false
		@OptionGroup
		private var requiredAppIDsOptionGroup: RequiredAppIDsOptionGroup

		func run() async throws {
			try run(installedApps: try await installedApps)
		}

		private func run(installedApps: [InstalledApp]) throws {
			let uninstallingAppByPath = requiredAppIDsOptionGroup.appIDs // swiftformat:disable indent
			.reduce(into: OrderedDictionary<String, InstalledApp>()) { uninstallingAppByPath, appID in
				let uninstallingApps = installedApps.filter { $0.matches(appID) }
				guard !uninstallingApps.isEmpty else {
					printer.error(appID.notInstalledMessage)
					return
				}

				for uninstallingApp in uninstallingApps {
					uninstallingAppByPath[uninstallingApp.path] = uninstallingApp
				}
			}
			guard !uninstallingAppByPath.isEmpty else { // swiftformat:enable indent
				return
			}
			guard !dryRun else {
				printer.notice("Dry run. A wet run would uninstall:\n")
				for appPath in uninstallingAppByPath.keys {
					printer.info(appPath)
				}
				return
			}
			guard getuid() == 0 else {
				try sudo(MAS._commandName, args: [Self._commandName] + uninstallingAppByPath.values.map { String($0.adamID) })
				return
			}

			let processInfo = ProcessInfo.processInfo
			let uid = try processInfo.sudoUID
			let gid = try processInfo.sudoGID
			let fileManager = FileManager.default
			for appPath in uninstallingAppByPath.keys {
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
								ofItemAtPath: chownPath
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
							error: error
						)
					}
				}

				var uninstalledAppURL = NSURL?.none // swiftlint:disable:this legacy_objc_type
				try fileManager.trashItem(
					at: URL(fileURLWithPath: appPath, isDirectory: true),
					resultingItemURL: &uninstalledAppURL
				)
				guard let uninstalledAppPath = uninstalledAppURL?.path else {
					printer.error(
						"""
						Failed to revert ownership of uninstalled \(appPath.quoted) back to uid \(appUID) & gid \(appGID):\
						 failed to obtain uninstalled app URL
						"""
					)
					continue
				}

				chownPath = uninstalledAppPath
				printer.info("Uninstalled", appPath.quoted, "to", chownPath.quoted)
			}
		}
	}
}
