//
//  Region.swift
//  mas
//
//  Created by Ross Goldberg on 2024-12-29.
//  Copyright (c) 2024 mas-cli. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Command which interacts with the current region for the Mac App Store.
	struct Region: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display the region of the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			guard let region = await isoRegion else {
				throw MASError.runtimeError("Could not obtain Mac App Store region")
			}

			print(region.alpha2)
		}
	}
}
