//
// Region.swift
// mas
//
// Created by Ross Goldberg on 2024-12-29.
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Displays the region of the Mac App Store.
	struct Region: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display the region of the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			guard let region = await isoRegion else {
				throw MASError.runtimeError("Could not obtain Mac App Store region")
			}

			printInfo(region.alpha2)
		}
	}
}
