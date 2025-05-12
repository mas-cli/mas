//
// SignOut.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import CommerceKit

extension MAS {
	/// Signs out of the Apple Account currently signed in to the Mac App Store.
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
