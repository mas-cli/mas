//
//  Account.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct AccountCommand: CommandType {
    typealias Options = NoOptions<MASError>
    let verb = "account"
    let function = "Prints the primary account Apple ID"
    
    func run(options: Options) -> Result<(), MASError> {
        if let account = ISStoreAccount.primaryAccount {
            print(account.identifier)
        }
        else {
            print("Not signed in")
            return .Failure(MASError(code: .NotSignedIn))
        }
        return .Success(())
    }
}
