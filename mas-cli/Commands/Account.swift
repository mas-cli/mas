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
            print(primaryAccount().identifier)
        default:
            break
        }
        return .success(())
    }
}