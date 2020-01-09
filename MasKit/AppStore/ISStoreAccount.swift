//
//  ISStoreAccount.swift
//  mas-cli
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import StoreFoundation

extension ISStoreAccount: StoreAccount {
    static var primaryAccountIsPresentAndSignedIn: Bool {
        return CKAccountStore.shared().primaryAccountIsPresentAndSignedIn
    }

    static var primaryAccount: StoreAccount? {
        var account: ISStoreAccount?

        if #available(macOS 10.13, *) {
            let group = DispatchGroup()
            group.enter()

            let accountService: ISAccountService = ISServiceProxy.genericShared().accountService
            accountService.primaryAccount { (storeAccount: ISStoreAccount) in
                account = storeAccount
                group.leave()
            }

            _ = group.wait(timeout: .now() + 30)
        } else {
            // macOS 10.9-10.12
            let accountStore = CKAccountStore.shared()
            account = accountStore.primaryAccount
        }

        return account
    }

    static func signIn(username: String, password: String, systemDialog: Bool = false) throws -> StoreAccount {
        var storeAccount: ISStoreAccount?
        var maserror: MASError?

        let accountService: ISAccountService = ISServiceProxy.genericShared().accountService
        let client = ISStoreClient(storeClientType: 0)
        accountService.setStoreClient(client)

        let context = ISAuthenticationContext(accountID: 0)
        context.appleIDOverride = username

        if systemDialog {
            context.appleIDOverride = username
        } else {
            context.demoMode = true
            context.demoAccountName = username
            context.demoAccountPassword = password
            context.demoAutologinMode = true
        }

        let group = DispatchGroup()
        group.enter()

        // Only works on macOS Sierra and below
        accountService.signIn(with: context) { success, account, error in
            if success {
                storeAccount = account
            } else {
                maserror = .signInFailed(error: error as NSError?)
            }
            group.leave()
        }

        if systemDialog {
            group.wait()
        } else {
            _ = group.wait(timeout: .now() + 30)
        }

        if let account = storeAccount {
            return account
        }

        throw maserror ?? MASError.signInFailed(error: nil)
    }
}
