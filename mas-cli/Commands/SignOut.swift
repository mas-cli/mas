//
//  SignOut.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

struct SignOutCommand: CommandType {
    typealias Options = NoOptions<MASError>
    let verb = "signout"
    let function = "Sign out of the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        CKAccountStore.shared().signOut()
        return .success(())
    }
}
