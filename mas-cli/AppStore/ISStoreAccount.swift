//
//  ISStoreAccount.swift
//  mas-cli
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

extension ISStoreAccount {
    static var primaryAccountIsPresentAndSignedIn: Bool {
        return CKAccountStore.sharedAccountStore().primaryAccountIsPresentAndSignedIn
    }
    
    static var primaryAccount: ISStoreAccount? {
        return CKAccountStore.sharedAccountStore().primaryAccount
    }
}
