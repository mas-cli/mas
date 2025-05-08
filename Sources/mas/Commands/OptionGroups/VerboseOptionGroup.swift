//
// VerboseOptionGroup.swift
// mas
//
// Created by Ross Goldberg on 2025-05-08.
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct VerboseOptionGroup: ParsableArguments {
	@Flag(help: "Display warnings about app IDs unknown to the Mac App Store")
	var verbose = false

	func printProblem(forError error: Error, expectedAppName appName: String) {
		guard case MASError.unknownAppID = error else {
			printError(error)
			return
		}
		if verbose {
			printWarning(error, "; was expected to identify ", appName, separator: "")
		}
	}
}
