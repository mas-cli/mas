//
// Region.swift
// mas
//
// Created by Ross Goldberg on 2024-12-29.
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the region of the Mac App Store.
	struct Region: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the region of the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			try await mas.run { try await run(printer: $0) }
		}

		func run(printer: Printer) async throws {
			guard let region = await isoRegion else {
				throw MASError.runtimeError("Failed to obtain the region of the Mac App Store")
			}
			printer.info(region.alpha2)
		}
	}
}
