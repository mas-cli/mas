//
// Account.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Outputs the Apple Account signed in to the Mac App Store.
	struct Account: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output the Apple Account signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			try await mas.run { try await run(printer: $0) }
		}

		func run(printer: Printer) async throws {
			guard let appleAccount = try await appleAccount.emailAddress else {
				throw MASError.runtimeError("Not signed in to an Apple Account in the Mac App Store")
			}

			printer.info(appleAccount)
		}
	}
}
