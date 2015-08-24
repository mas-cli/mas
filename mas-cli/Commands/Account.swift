//
//  Account.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct AccountCommand: CommandType {
    let verb = "account"
    let function = "Prints the primary account Apple ID"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            if let account = ISStoreAccount.primaryAccount {
                println(account.identifier)
            }
            else {
                println("Not signed in")
                exit(MASErrorCode.NotSignedIn.exitCode)
            }
        default:
            break
        }
        return .success(())
    }
}
