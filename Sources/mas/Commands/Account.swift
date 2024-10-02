//
//  Account.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import StoreFoundation

extension Mas {
    struct Account: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Prints the primary account Apple ID"
        )

        /// Runs the command.
        func run() throws {
            if #available(macOS 12, *) {
                // Account information is no longer available as of Monterey.
                // https://github.com/mas-cli/mas/issues/417
                throw MASError.notSupported
            }

            if let account = ISStoreAccount.primaryAccount {
                print(String(describing: account.identifier))
            } else {
                printError("Not signed in")
                throw MASError.notSignedIn
            }
        }
    }
}
