//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation
private import JSONAST
private import JSONParsing

extension MAS {
	/// Outputs a list of installed apps which have updates available to be
	/// installed from the App Store.
	struct Outdated: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List pending app updates from the App Store",
		)

		@OptionGroup
		private var outputFormatOptionGroup: OutputFormatOptionGroup
		@OptionGroup
		private var outdatedAppOptionGroup: OutdatedAppOptionGroup
		@OptionGroup
		private var verboseOptionGroup: VerboseOptionGroup
		@OptionGroup
		private var installedAppIDsOptionGroup: InstalledAppIDsOptionGroup

		func run() async throws {
			await run(installedApps: try await installedApps.filter(!\.isTestFlight))
		}

		private func run(installedApps: [InstalledApp]) async {
			run(
				outdatedApps: await installedApps.outdatedApps(
					filterFor: installedAppIDsOptionGroup.appIDs,
					accuracy: outdatedAppOptionGroup.accuracy,
					shouldCheckMinimumOSVersion: outdatedAppOptionGroup.shouldCheckMinimumOSVersion,
					shouldWarnIfUnknownApp: verboseOptionGroup.verbose,
				),
			)
		}

		private func run(outdatedApps: [OutdatedApp]) {
			guard !outdatedApps.isEmpty else {
				return
			}

			outputFormatOptionGroup.info(
				outdatedApps.compactMap { installedApp, newVersion in
					do {
						let newVersionKey = "newVersion"
						var json = try JSON.Object(parsing: String(describing: installedApp))
						json.fields.insert(
							(JSON.Key(rawValue: newVersionKey), JSON.Node.string(JSON.Literal(newVersion))),
							at: json.fields.enumerated().first { newVersionKey < $1.key.rawValue }?.offset ?? json.fields.count,
						) // swiftlint:disable:previous unused_enumerated
						return String(json)
					} catch {
						printer.error("Failed to parse outdated app JSON", installedApp, error: error, separator: "\n")
						return nil
					}
				}
				.joined(separator: "\n"),
			)
		}
	}
}
