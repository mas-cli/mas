//
// Reset.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import CommerceKit

extension MAS {
	/// Attempts to fix certain App Store-related issues by restarting background processes.
	///
	/// This command resets the App Store state by force-killing several background services
	/// used by the App Store and removing the download cache directory.
	///
	/// It may help resolve issues where you can’t install or upgrade apps using `mas`,
	/// or when you receive errors about your Apple account not being authorized.
	///
	/// > Tip:
	/// > Try this command if `mas install` or `mas upgrade` fails unexpectedly.
	///
	/// > Note:
	/// > This command performs actions similar to the App Store's hidden "Reset Application" debug option.
	///
	/// Example:
	/// ```bash
	/// mas reset
	/// ```
	///
	/// Use `--debug` to print detailed error output when the reset process encounters problems.
	struct Reset: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Reset Mac App Store running processes"
		)

		@Flag(help: "Output debug information")
		var debug = false

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		func run(printer: Printer) {
			// The "Reset Application" command in the Mac App Store debug menu performs
			// the following steps
			//
			// - killall Dock
			// - killall storeagent (storeagent no longer exists)
			// - rm com.apple.appstore download directory
			// - clear cookies (appears to be a no-op)
			//
			// As storeagent no longer exists we will implement a slight variant & kill all
			// App Store-associated processes
			// - storeaccountd
			// - storeassetd
			// - storedownloadd
			// - storeinstalld
			// - storelegacy

			// Kill processes
			let killProcs = [
				"Dock",
				"storeaccountd",
				"storeassetd",
				"storedownloadd",
				"storeinstalld",
				"storelegacy",
			]

			let kill = Process()
			let stdout = Pipe()
			let stderr = Pipe()

			kill.launchPath = "/usr/bin/killall"
			kill.arguments = killProcs
			kill.standardOutput = stdout
			kill.standardError = stderr

			kill.launch()
			kill.waitUntilExit()

			if kill.terminationStatus != 0 {
				let output = stderr.fileHandleForReading.readDataToEndOfFile()
				printer.error(
					"killall failed:",
					String(data: output, encoding: .utf8) ?? "Error info not available",
					separator: "\n"
				)
			}

			// Wipe Download Directory
			if let directory = CKDownloadDirectory(nil) {
				do {
					try FileManager.default.removeItem(atPath: directory)
				} catch {
					printer.error("Failed to delete download directory", directory, error: error)
				}
			}
		}
	}
}
