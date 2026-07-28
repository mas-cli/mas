//
// MAS.Uninstall.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation
private import OrderedCollections
private import Subprocess
private import System // swiftlint:disable:this unused_import

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
		private var installedAppsOptionGroup: InstalledAppsOptionGroup

		func validate() throws(ValidationError) {
			if isUninstallingAll != installedAppsOptionGroup.appIDStrings.isEmpty {
				throw .init(
					isUninstallingAll
						? "Cannot specify both --all & app IDs"
						: "Must specify either --all or at least one app ID",
				)
			}
		}

		func run() async {
			let installedApps = await installedAppsOptionGroup.installedApps(withFullJSON: false)
			let uninstallingADAMIDByPathOrdered =
				(isUninstallingAll ? installedApps.map { .bundleID($0.bundleID) } : installedAppsOptionGroup.appIDs)
					.reduce(into: OrderedDictionary<String, String>()) { uninstallingADAMIDByPathOrdered, appID in
						uninstallingADAMIDByPathOrdered
							.merge(installedApps.compactMap { $0.matches(appID) ? ($0.path, .init($0.adamID)) : nil }) { $1 }
					}
			guard !uninstallingADAMIDByPathOrdered.isEmpty else {
				return
			}
			guard !isPerformingDryRun else {
				printer.notice("Dry run. A wet run would uninstall:\n")
				for appPath in uninstallingADAMIDByPathOrdered.keys {
					printer.info(appPath)
				}
				return
			}

			let fileManager = FileManager.default
			for appPath in uninstallingADAMIDByPathOrdered.keys {
				do {
					let appURL = URL(folderPath: appPath)
					let trashURL = try fileManager.url(
						for: .trashDirectory,
						in: .userDomainMask,
						appropriateFor: appURL,
						create: true,
					)
					let destinationPath = trashURL.appending(path: appURL.lastPathComponent, directoryHint: .isDirectory).filePath
					_ = try await mas::run(
						.path("/usr/bin/sudo"),
						"/bin/mv",
						appPath,
						fileManager.fileExists(atPath: destinationPath)
							? trashURL.appending(
								path: """
									\(appURL.deletingPathExtension().lastPathComponent) \
									\(Date().formatted(trashCollisionDateFormatStyle))\
									\(appURL.pathExtension.ifNotEmptyPrepend("."))
									""",
								directoryHint: .isDirectory,
							)
							.filePath
							: destinationPath,
						errorMessage: "Failed to trash \(appPath.quoted) to \(destinationPath.quoted)",
					)
					printer.info("Uninstalled", appPath.quoted, "to", destinationPath.quoted)
				} catch {
					printer.error("Failed to uninstall", appPath, error: error)
				}
			}
		}
	}
}

private let trashCollisionDateFormatStyle = Date.VerbatimFormatStyle( // editorconfig-checker-disable
	format: """
		\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased)).\(minute: .twoDigits).\(second: .twoDigits)\
		 \(dayPeriod: .standard(.narrow))
		""", // editorconfig-checker-enable
	timeZone: .current,
	calendar: .current,
)
