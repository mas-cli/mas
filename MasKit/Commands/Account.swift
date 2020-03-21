//
//  Account.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import StoreFoundation

public struct AccountCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "account"
    public let function = "Prints the primary account Apple ID"

    public init() {}

    /// Runs the command.
    public func run(_: Options) -> Result<(), MASError> {
        if let account = ISStoreAccount.primaryAccount {
            print(String(describing: account.identifier))
        } else {
            print("Not signed in")
            return .failure(.notSignedIn)
        }
        return .success(())
    }
}
