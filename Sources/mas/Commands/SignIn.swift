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
            let result = runInternal()
            if case .failure = result {
                try result.get()
            }
        }

        func runInternal() -> Result<Void, MASError> {
            if #available(macOS 10.13, *) {
                // Signing in is no longer possible as of High Sierra.
                // https://github.com/mas-cli/mas/issues/164
                return .failure(.notSupported)
            }

            guard ISStoreAccount.primaryAccount == nil else {
                return .failure(.alreadySignedIn)
            }

            do {
                printInfo("Signing in to Apple ID: \(username)")

                let pwd: String = {
                    if password.isEmpty, !dialog {
                        return String(validatingUTF8: getpass("Password: "))!
                    }
                    return password
                }()

                _ = try ISStoreAccount.signIn(username: username, password: pwd, systemDialog: dialog)
            } catch let error as NSError {
                return .failure(.signInFailed(error: error))
            }

            return .success(())
        }
    }
}
