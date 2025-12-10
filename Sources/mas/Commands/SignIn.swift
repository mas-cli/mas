//
// SignIn.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Signs in to an Apple Account in the App Store.
	struct SignIn: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signin",
			abstract: "Sign in to an Apple Account in the App Store"
		)

		// periphery:ignore
		@Flag(help: "Provide password via graphical dialog") // swiftformat:disable:next unusedPrivateDeclarations
		private var dialog = false // swiftlint:disable:this unused_declaration
		// periphery:ignore
		@Argument(help: "Apple Account") // swiftformat:disable:next unusedPrivateDeclarations
		private var appleAccount: String // swiftlint:disable:this unused_declaration
		// periphery:ignore
		@Argument(help: "Password") // swiftformat:disable:next unusedPrivateDeclarations
		private var password = "" // swiftlint:disable:this unused_declaration

		func run() throws {
			// Signing in is no longer possible starting with macOS 10.13 (High Sierra)
			// https://github.com/mas-cli/mas/issues/164
			throw MASError.unsupportedCommand(Self._commandName)
		}
	}
}
