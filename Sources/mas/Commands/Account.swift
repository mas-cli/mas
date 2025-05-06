//
// Account.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser
private import StoreFoundation

extension MAS {
	struct Account: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display the Apple Account signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			printInfo(try await appleAccount.emailAddress)
		}
	}
}
