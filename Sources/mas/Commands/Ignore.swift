//
// Ignore.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	struct Ignore: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Manage ignored apps and versions",
			subcommands: [Add.self, Remove.self, List.self, Clear.self]
		)
	}
}

private func promptYesNo(_ message: String) -> Bool {
	MAS.printer.info(message, terminator: " ")
	guard let response = readLine() else {
		return false
	}

	let normalized = response.trimmingCharacters(in: .whitespaces).lowercased()
	// Default to "yes" if user just presses ENTER
	return normalized.isEmpty || normalized == "y" || normalized == "yes"
}

extension MAS.Ignore {
	struct Add: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Add an app or app version to the ignore list"
		)

		@Argument(help: "App ID to ignore")
		var adamID: ADAMID

		@Option(name: .shortAndLong, help: "Specific version to ignore (optional)")
		var version: String?

		@Flag(name: .shortAndLong, help: "Skip confirmation prompts")
		var yes = false

		func run() async throws {
			let cleanedVersion = version?.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
			let ignoreList = IgnoreList.shared

			// Case 1: User wants to add a specific version, but all versions are already ignored
			if let cleanedVersion, await ignoreList.hasAllVersionsIgnore(adamID: adamID) {
				MAS.printer.warning(
					"App \(adamID) already has all versions ignored."
				)
				if yes || promptYesNo("Replace with version-specific ignore for \(cleanedVersion)? [Y/n]:") {
					// Remove the all-versions entry
					try await ignoreList.remove(IgnoreEntry(adamID: adamID, version: nil))
					// Add the specific version entry
					let entry = IgnoreEntry(adamID: adamID, version: cleanedVersion)
					try await ignoreList.add(entry)
					MAS.printer.info("Replaced all-versions ignore with version-specific ignore for \(cleanedVersion)")
				} else {
					MAS.printer.info("Keeping existing all-versions ignore")
				}
				return
			}

			// Case 2: User wants to ignore all versions, but specific versions are already ignored
			if cleanedVersion == nil, await ignoreList.hasSpecificVersionIgnores(adamID: adamID) {
			let existingEntries = await ignoreList.entriesFor(adamID: adamID)
			let versions = existingEntries.compactMap { $0.version } // swiftlint:disable:this prefer_key_path
				let versionsList = versions.sorted().joined(separator: ", ")
				MAS.printer.warning(
					"App \(adamID) already has specific version(s) ignored: \(versionsList)"
				)
				if yes || promptYesNo("Replace with all-versions ignore? [Y/n]:") {
					// Remove all existing entries for this adamID
					try await ignoreList.removeAll(forADAMID: adamID)
					// Add the all-versions entry
					let entry = IgnoreEntry(adamID: adamID, version: nil)
					try await ignoreList.add(entry)
					MAS.printer.info("Replaced version-specific ignores with all-versions ignore")
				} else {
					MAS.printer.info("Keeping existing version-specific ignores")
				}
				return
			}

			// Normal case: no conflicts
			let entry = IgnoreEntry(adamID: adamID, version: cleanedVersion)
			try await ignoreList.add(entry)

			if let cleanedVersion {
				MAS.printer.info("Ignoring \(adamID) version \(cleanedVersion)")
			} else {
				MAS.printer.info("Ignoring all versions of \(adamID)")
			}
		}
	}

	struct Remove: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Remove an app or app version from the ignore list"
		)

		@Argument(help: "App ID to stop ignoring")
		var adamID: ADAMID

		@Option(name: .shortAndLong, help: "Specific version to stop ignoring (optional)")
		var version: String?

		@Flag(name: .shortAndLong, help: "Remove all ignore entries for this app ID")
		var all = false

		func run() async throws {
			if all {
				try await IgnoreList.shared.removeAll(forADAMID: adamID)
				MAS.printer.info("Removed all ignore entries for \(adamID)")
			} else {
				let cleanedVersion = version?.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
				let entry = IgnoreEntry(adamID: adamID, version: cleanedVersion)
				try await IgnoreList.shared.remove(entry)

				if let cleanedVersion {
					MAS.printer.info("No longer ignoring \(adamID) version \(cleanedVersion)")
				} else {
					MAS.printer.info("No longer ignoring all versions of \(adamID)")
				}
			}
		}
	}

	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List all ignored apps and versions"
		)

		func run() async {
			let entries = await IgnoreList.shared.all()

			guard !entries.isEmpty else {
				MAS.printer.info("No ignored apps")
				return
			}

			let maxADAMIDLength = entries.map { String(describing: $0.adamID).count }.max() ?? 0
			let format = "%\(maxADAMIDLength)lu  %@"

			MAS.printer.info(
				entries.map { entry in
					String(
						format: format,
						entry.adamID,
						entry.version ?? "(all versions)"
					)
				}
				.joined(separator: "\n")
			)
		}
	}

	struct Clear: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Clear all ignored apps and versions"
		)

		func run() async throws {
			let entries = await IgnoreList.shared.all()
			for entry in entries {
				try await IgnoreList.shared.remove(entry)
			}
			MAS.printer.info("Cleared all ignore entries")
		}
	}
}
