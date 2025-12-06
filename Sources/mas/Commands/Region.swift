//
// Region.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the region of the App Store.
	struct Region: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the region of the App Store"
		)

		func run() {
			printer.info(region)
		}
	}
}
