//
//  ISStoreAccount.swift
//  mas-cli
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit
import StoreFoundation

extension ISStoreAccount: StoreAccount {
    static var primaryAccount: Promise<ISStoreAccount> {
        if #available(macOS 10.13, *) {
            return race(
                Promise<ISStoreAccount> { seal in
                    ISServiceProxy.genericShared().accountService.primaryAccount { storeAccount in
                        seal.fulfill(storeAccount)
                    }
                },
                after(seconds: 30).then {
                    Promise(error: MASError.notSignedIn)
                }
            )
        } else {
            return .value(CKAccountStore.shared().primaryAccount)
        }
    }

    static func signIn(username: String, password: String, systemDialog: Bool) -> Promise<ISStoreAccount> {
        if #available(macOS 10.13, *) {
            // Signing in is no longer possible as of High Sierra.
            // https://github.com/mas-cli/mas/issues/164
            return Promise(error: MASError.notSupported)
        } else {
            return
                primaryAccount
                .then { account -> Promise<ISStoreAccount> in
                    if account.isSignedIn {
                        return Promise(error: MASError.alreadySignedIn(asAccountId: account.identifier))
                    }

                    let password =
                        password.isEmpty && !systemDialog
                        ? String(validatingUTF8: getpass("Password: "))!
                        : password

                    guard !password.isEmpty || systemDialog else {
                        return Promise(error: MASError.noPasswordProvided)
                    }

                    let context = ISAuthenticationContext(accountID: 0)
                    context.appleIDOverride = username

                    let signInPromise =
                        Promise<ISStoreAccount> { seal in
                            let accountService = ISServiceProxy.genericShared().accountService
                            accountService.setStoreClient(ISStoreClient(storeClientType: 0))
                            accountService.signIn(with: context) { success, storeAccount, error in
                                if success, let storeAccount {
                                    seal.fulfill(storeAccount)
                                } else {
                                    seal.reject(MASError.signInFailed(error: error as NSError?))
                                }
                            }
                        }

                    if systemDialog {
                        return signInPromise
                    } else {
                        context.demoMode = true
                        context.demoAccountName = username
                        context.demoAccountPassword = password
                        context.demoAutologinMode = true

                        return race(
                            signInPromise,
                            after(seconds: 30).then {
                                Promise(error: MASError.signInFailed(error: nil))
                            }
                        )
                    }
                }
        }
    }
}
