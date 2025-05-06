//
// SignOut.swift
// mas
//
// Created by Andrew Naylor on 2016-02-14.
// Copyright © 2016 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser
private import CommerceKit

extension MAS {
	struct SignOut: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "signout",
			abstract: "Sign out of the Apple Account currently signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() throws {
			ISServiceProxy.genericShared().accountService.signOut()
		}
	}
}
