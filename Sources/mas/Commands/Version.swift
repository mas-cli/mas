//
// Version.swift
// mas
//
// Created by Andrew Naylor on 2015-09-20.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Command which displays the version of the mas tool.
	struct Version: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display version number"
		)

		/// Runs the command.
		func run() throws {
			printInfo(Package.version)
		}
	}
}
