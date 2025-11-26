//
// Account.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the Apple Account signed in to the App Store.
	struct Account: ParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the Apple Account signed in to the App Store"
		)

		func run() throws {
			// Account information is no longer available starting with macOS 12 (Monterey)
			// https://github.com/mas-cli/mas/issues/417
			throw MASError.unsupportedCommand(MAS.Account._commandName)
		}
	}
}
