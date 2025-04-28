//
//  Account.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import StoreFoundation

extension MAS {
	struct Account: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Display the Apple Account signed in to the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			if #available(macOS 12, *) {
				// Account information is no longer available as of Monterey.
				// https://github.com/mas-cli/mas/issues/417
				throw MASError.notSupported
			}

			print(await ISStoreAccount.primaryAccount.identifier)
		}
	}
}
