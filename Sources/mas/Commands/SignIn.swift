//
// SignIn.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// **Deprecated:** Signs in to an Apple Account in the Mac App Store (unsupported on modern macOS).
	///
	/// This command was used to sign in with an Apple ID on macOS 10.12 (Sierra) and earlier.
	/// It is **not supported** on macOS 10.13 (High Sierra) or newer due to Apple’s changes
	/// to undocumented private frameworks.
	///
	/// > Important:
	/// > On macOS 10.13 and later, please sign in manually using the App Store app.
	///
	/// > Warning:
	/// > Attempting to use this command on newer versions will result in an error.
	///
	/// Example (legacy only):
	/// ```bash
	/// mas signin mas@example.com
	/// Password:
	/// ```
	///
	/// With dialog (legacy only):
	/// ```bash
	/// mas signin --dialog mas@example.com
	/// ```
	///
	/// With embedded password (not recommended):
	/// ```bash
	/// mas signin mas@example.com MyPassword
	/// ```
	///
	/// See also:
	/// [Known Issue #164](https://github.com/mas-cli/mas/issues/164)
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
