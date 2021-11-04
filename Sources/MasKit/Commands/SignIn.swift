//
//  SignIn.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import StoreFoundation

public struct SignInCommand: CommandProtocol {
    public typealias Options = SignInOptions

    public let verb = "signin"
    public let function = "Sign in to the Mac App Store"

    public init() {}

    /// Runs the command.
    public func run(_ options: Options) -> Result<Void, MASError> {
        if #available(macOS 10.13, *) {
            // Signing in is no longer possible as of High Sierra.
            // https://github.com/mas-cli/mas/issues/164
            return .failure(.notSupported)
        }

        guard ISStoreAccount.primaryAccount == nil else {
            return .failure(.alreadySignedIn)
        }

        do {
            printInfo("Signing in to Apple ID: \(options.username)")

            let password: String = {
                if options.password.isEmpty, !options.dialog {
                    return String(validatingUTF8: getpass("Password: "))!
                }
                return options.password
            }()

            _ = try ISStoreAccount.signIn(username: options.username, password: password, systemDialog: options.dialog)
        } catch let error as NSError {
            return .failure(.signInFailed(error: error))
        }

        return .success(())
    }
}

public struct SignInOptions: OptionsProtocol {
    public typealias ClientError = MASError

    let username: String
    let password: String
    let dialog: Bool

    static func create(username: String) -> (_ password: String) -> (_ dialog: Bool) -> SignInOptions {
        { password in { dialog in SignInOptions(username: username, password: password, dialog: dialog) } }
    }

    public static func evaluate(_ mode: CommandMode) -> Result<SignInOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(usage: "Apple ID")
            <*> mode <| Argument(defaultValue: "", usage: "Password")
            <*> mode <| Option(key: "dialog", defaultValue: false, usage: "Complete login with graphical dialog")
    }
}
