//
//  ISStoreAccount.swift
//  mas-cli
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

extension ISStoreAccount {
    static var primaryAccountIsPresentAndSignedIn: Bool {
        return CKAccountStore.shared().primaryAccountIsPresentAndSignedIn
    }

    static var primaryAccount: ISStoreAccount? {
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

    static func signIn(username: String, password: String, systemDialog: Bool = false) throws -> ISStoreAccount {
        var account: ISStoreAccount? = nil
        var error: MASError? = nil

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
        accountService.signIn(with: context) { success, _account, _error in
            if success {
                account = _account
            } else {
                error = .signInFailed(error: _error as NSError?)
            }
            group.leave()
        }

        if systemDialog {
            group.wait()
        } else {
            let _ = group.wait(timeout: .now() + 30)
        }
        
        if let account = account {
            return account
        }
        
        throw error ?? MASError.signInFailed(error: nil)
    }
}
