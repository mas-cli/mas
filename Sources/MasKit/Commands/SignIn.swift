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
        do {
            _ = try ISStoreAccount.signIn(
                username: options.username,
                password: options.password,
                systemDialog: options.dialog
            )
            return .success(())
        } catch {
            return .failure(error as? MASError ?? .signInFailed(error: error as NSError))
        }
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
