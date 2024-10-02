//
//  SignIn.swift
//  mas
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import StoreFoundation

extension Mas {
    struct SignIn: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "signin",
            abstract: "Sign in to the Mac App Store"
        )

        @Flag(help: "Complete login with graphical dialog")
        var dialog = false
        @Argument(help: "Apple ID")
        var username: String
        @Argument(help: "Password")
        var password: String = ""

        /// Runs the command.
        func run() throws {
            do {
                _ = try ISStoreAccount.signIn(username: username, password: password, systemDialog: dialog).wait()
            } catch {
                throw error as? MASError ?? MASError.signInFailed(error: error as NSError)
            }
        }
    }
}
