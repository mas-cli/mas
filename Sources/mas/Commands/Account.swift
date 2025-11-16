//
// Account.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the Apple Account signed in to the Mac App Store.
	struct Account: AsyncParsableCommand, Sendable {
		static let configuration = CommandConfiguration(
			abstract: "Output the Apple Account signed in to the Mac App Store"
		)

		func run() async {
			do {
				guard let appleAccount = try await appleAccount.emailAddress else {
					printer.error("Not signed in to an Apple Account in the Mac App Store")
					return
				}

				printer.info(appleAccount)
			} catch {
				printer.error(error: error)
			}
		}
	}
}
