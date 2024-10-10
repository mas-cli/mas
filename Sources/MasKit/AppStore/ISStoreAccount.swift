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
    static var primaryAccount: ISStoreAccount? {
        if #available(macOS 10.13, *) {
            let group = DispatchGroup()
            group.enter()

            var account: ISStoreAccount?
            ISServiceProxy.genericShared().accountService.primaryAccount { storeAccount in
                account = storeAccount
                group.leave()
            }

            _ = group.wait(timeout: .now() + 30)

            return account
        } else {
            return CKAccountStore.shared().primaryAccount
        }
    }

    static func signIn(username: String, password: String, systemDialog: Bool = false) throws -> ISStoreAccount {
        if #available(macOS 10.13, *) {
            // Signing in is no longer possible as of High Sierra.
            // https://github.com/mas-cli/mas/issues/164
            throw MASError.notSupported
        } else {
            let primaryAccount = primaryAccount
            if primaryAccount != nil {
                throw MASError.alreadySignedIn(asAccountId: primaryAccount!.identifier)
            }

            let password =
                password.isEmpty && !systemDialog
                ? String(validatingUTF8: getpass("Password: "))!
                : password

            let accountService = ISServiceProxy.genericShared().accountService
            accountService.setStoreClient(ISStoreClient(storeClientType: 0))

            let context = ISAuthenticationContext(accountID: 0)
            context.appleIDOverride = username
            if !systemDialog {
                context.demoMode = true
                context.demoAccountName = username
                context.demoAccountPassword = password
                context.demoAutologinMode = true
            }

            let group = DispatchGroup()
            group.enter()

            var storeAccount: ISStoreAccount?
            var maserror: MASError?
            // Only works on macOS Sierra and below
            accountService.signIn(with: context) { success, account, error in
                if success, let account {
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

            if let storeAccount {
                return storeAccount
            }

            throw maserror ?? MASError.signInFailed(error: nil)
        }
    }
}
