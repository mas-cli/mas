//
// Outdated.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import JSON
private import JSONAST

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

		func run() async throws {
			await run(
				installedApps: // swiftformat:disable:next indent
					try await installedApps(withFullJSON: outputFormatOptionGroup.shouldOutputJSON).filter(!\.isTestFlight),
			)
		}

		private func run(installedApps: [InstalledApp]) async {
			run(outdatedApps: await outdatedAppOptionGroup.outdatedApps(from: installedApps))
		}

		private func run(outdatedApps: [OutdatedApp]) {
			if !outdatedApps.isEmpty {
				outputFormatOptionGroup.info(outdatedApps.map { .init(describing: $0) }.joined(separator: "\n"))
			}
		}
	}
}
