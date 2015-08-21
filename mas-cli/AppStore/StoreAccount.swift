//
//  Account.swift
//  mas-cli
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

func primaryAccount() -> ISStoreAccount {
    let accountController = CKAccountStore.sharedAccountStore()
    return accountController.primaryAccount
}
