//
// SignIn.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Signs in to an Apple Account in the Mac App Store.
	struct SignIn: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signin",
			abstract: "Sign in to an Apple Account in the Mac App Store"
		)

		@Flag(help: "Provide password via graphical dialog")
		var dialog = false // swiftlint:disable:this unused_declaration
		// periphery:ignore
		@Argument(help: "Apple Account")
		var appleAccount: String // swiftlint:disable:this unused_declaration
		@Argument(help: "Password")
		var password = "" // swiftlint:disable:this unused_declaration

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		func run(printer: Printer) {
			// Signing in is no longer possible as of High Sierra.
			// https://github.com/mas-cli/mas/issues/164
			printer.error(error: MASError.notSupported)
		}
	}
}
