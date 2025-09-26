//
// Version.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the version of mas.
	struct Version: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output version number"
		)

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		func run(printer: Printer) {
			printer.info(MAS.version)
		}
	}
}
