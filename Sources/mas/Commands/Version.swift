//
// Version.swift
// mas
//
// Created by Andrew Naylor on 2015-09-20.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the version of the mas tool.
	struct Version: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output version number"
		)

		/// Runs the command.
		func run() {
			printInfo(Package.version)
		}
	}
}
