//
// SignOut.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	/// Signs out of the Apple Account currently signed in to the Mac App Store.
	struct SignOut: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signout",
			abstract: "Sign out of the Apple Account currently signed in to the Mac App Store"
		)

		func run() throws {
			try MAS.run { run(printer: $0) }
		}

		private func run(printer _: Printer) {
			ISServiceProxy.genericShared().accountService.signOut()
		}
	}
}
