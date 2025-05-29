//
// Account.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the Apple Account signed in to the Mac App Store.
	/// Outputs the Apple Account signed in to the Mac App Store.
	///
	/// > Warning:
	/// > This command is **not supported on macOS 12 (Monterey) or newer** due to Apple changing private frameworks.
	/// > See [Issue #417](https://github.com/mas-cli/mas/issues/417) for more details.
	///
	/// > Note:
	/// > mas uses private Apple frameworks for this command, which are undocumented and subject to change.
	/// > Functionality may break without notice in future macOS versions.
	struct Account: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the Apple Account signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			try await mas.run { try await run(printer: $0) }
		}

		func run(printer: Printer) async throws {
			printer.info(try await appleAccount.emailAddress)
		}
	}
}
