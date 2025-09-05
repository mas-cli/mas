//
// VerboseOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct VerboseOptionGroup: ParsableArguments {
	@Flag(help: "Output warnings about app IDs unknown to the Mac App Store")
	var verbose = false

	func printProblem(forError error: any Error, expectedAppName appName: String, printer: Printer) {
		guard case MASError.unknownAppID = error else {
			printer.error(error: error)
			return
		}

		if verbose {
			printer.warning(error, "; was expected to identify: ", appName, separator: "")
		}
	}
}
