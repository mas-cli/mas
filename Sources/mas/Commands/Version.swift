//
// Version.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the version number of the `mas` CLI tool.
	///
	/// This command prints the current version of the installed `mas` binary.
	/// It is useful for checking compatibility, submitting bug reports,
	/// or verifying that an upgrade was successful.
	///
	/// > Note:
	/// > For full version and environment details, use `mas config`.
	///
	/// Example:
	/// ```bash
	/// mas version
	/// ```
	///
	/// Output:
	/// ```
	/// 2.2.2
	/// ```
	struct Version: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output version number"
		)

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		func run(printer: Printer) {
			printer.info(Package.version)
		}
	}
}
