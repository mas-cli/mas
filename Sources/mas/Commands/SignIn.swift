//
//  SignIn.swift
//  mas
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import StoreFoundation

extension MAS {
    struct SignIn: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "signin",
            abstract: "Sign in to an Apple ID in the Mac App Store"
        )

        @Flag(help: "Provide password via graphical dialog")
        var dialog = false
        @Argument(help: "Apple ID")
        var appleID: String
        @Argument(help: "Password")
        var password = ""

        /// Runs the command.
        func run() throws {
            do {
                _ = try ISStoreAccount.signIn(appleID: appleID, password: password, systemDialog: dialog).wait()
            } catch {
                throw error as? MASError ?? MASError.signInFailed(error: error as NSError)
            }
        }
    }
}
