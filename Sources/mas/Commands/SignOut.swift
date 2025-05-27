//
// SignOut.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import CommerceKit

extension MAS {
	/// Signs out of the currently logged-in Apple Account in the Mac App Store.
	///
	/// This command logs out the active Apple ID used by the App Store on this Mac.
	/// It is useful when switching accounts, resetting authentication, or preparing
	/// for clean automation in CI environments.
	///
	/// > Note:
	/// > You can verify your login status with `mas account`.
	///
	/// Example:
	/// ```bash
	/// mas signout
	/// ```
	struct SignOut: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signout",
			abstract: "Sign out of the Apple Account currently signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() throws {
			try mas.run { run(printer: $0) }
		}

		func run(printer _: Printer) {
			ISServiceProxy.genericShared().accountService.signOut()
		}
	}
}
