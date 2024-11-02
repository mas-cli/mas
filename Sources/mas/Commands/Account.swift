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
    struct Account: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display the Apple ID signed in in the Mac App Store"
        )

        /// Runs the command.
        func run() throws {
            if #available(macOS 12, *) {
                // Account information is no longer available as of Monterey.
                // https://github.com/mas-cli/mas/issues/417
                throw MASError.notSupported
            }

            do {
                print(try ISStoreAccount.primaryAccount.wait().identifier)
            } catch {
                throw error as? MASError ?? MASError.failed(error: error as NSError)
            }
        }
    }
}
