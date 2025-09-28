//
// Region.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the region of the Mac App Store.
	struct Region: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the region of the Mac App Store"
		)

		func run() async throws {
			try await MAS.run { await run(printer: $0) }
		}

		func run(printer: Printer) async {
			printer.info(await region)
		}
	}
}
