//
// Reset.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import CommerceKit

extension MAS {
	/// Terminates several macOS processes & deletes files to reset the Mac App
	/// Store.
	struct Reset: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Reset Mac App Store processes"
		)

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		/// The "Reset Application" command in the Mac App Store debug menu performs
		/// the following steps:
		///
		/// - `killall Dock`
		/// - `killall storeagent` (`storeagent` no longer exists)
		/// - deletes the `com.apple.appstore` download folder
		/// - clears cookies (appears to be a no-op)
		///
		/// As `storeagent` no longer exists, terminates all processes known to be
		/// associated with the Mac App Store.
		func run(printer: Printer) {
			let killall = Process()
			killall.launchPath = "/usr/bin/killall"
			killall.arguments = [
				"ContextStoreAgent",
				"Dock",
				"SetStoreUpdateService",
				"appstoreagent",
				"appstorecomponentsd",
				"storeaccountd",
				"storeassetd",
				"storedownloadd",
				"storeinstalld",
				"storekitagent",
				"storelegacy",
				"storeuid",
			]
			let stderr = Pipe()
			killall.standardError = stderr
			killall.standardOutput = Pipe()

			killall.launch()
			killall.waitUntilExit()
			if killall.terminationStatus != 0 {
				let output = stderr.fileHandleForReading.readDataToEndOfFile()
				printer.error(
					"killall failed with exit status ",
					killall.terminationStatus,
					":\n",
					String(data: output, encoding: .utf8) ?? "Error info not available",
					separator: ""
				)
			}

			let folder = CKDownloadDirectory(nil)
			do {
				try FileManager.default.removeItem(atPath: folder)
			} catch {
				printer.error("Failed to delete download folder", folder, error: error)
			}
		}
	}
}
