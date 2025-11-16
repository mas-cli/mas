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

		func run() {
			printer.info(MAS.version)
		}
	}
}
