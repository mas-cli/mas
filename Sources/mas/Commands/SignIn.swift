//
// SignIn.swift
// mas
//
// Created by Andrew Naylor on 2016-02-14.
// Copyright © 2016 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	struct SignIn: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signin",
			abstract: "Sign in to an Apple Account in the Mac App Store"
		)

		@Flag(help: "Provide password via graphical dialog")
		var dialog = false
		// periphery:ignore
		@Argument(help: "Apple Account")
		var appleAccount: String
		@Argument(help: "Password")
		var password = ""

		/// Runs the command.
		func run() throws {
			// Signing in is no longer possible as of High Sierra.
			// https://github.com/mas-cli/mas/issues/164
			throw MASError.notSupported
		}
	}
}
