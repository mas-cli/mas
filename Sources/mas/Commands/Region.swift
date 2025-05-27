//
// Region.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Displays the current region setting for the Mac App Store.
	///
	/// The output is a two-letter country code (e.g., `US`, `JP`, `FR`)
	/// indicating the App Store region your system is currently using.
	///
	/// This region affects search results, app availability, and pricing.
	///
	/// > Note:
	/// > The region is typically based on your macOS locale or Apple ID configuration.
	///
	/// Example:
	/// ```bash
	/// mas region
	/// ```
	///
	/// Output:
	/// ```
	/// US
	/// ```
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
