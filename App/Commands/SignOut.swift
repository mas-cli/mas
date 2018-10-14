//
//  SignOut.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

struct SignOutCommand: CommandProtocol {
    typealias Options = NoOptions<MASError>
    let verb = "signout"
    let function = "Sign out of the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        if #available(macOS 10.13, *) {
            let accountService: ISAccountService = ISServiceProxy.genericShared().accountService
            accountService.signOut()
        }
        else {
            // Using CKAccountStore to sign out does nothing on High Sierra
            // https://github.com/mas-cli/mas/issues/129
            CKAccountStore.shared().signOut()
        }

        return .success(())
    }
}
