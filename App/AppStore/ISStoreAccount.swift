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
        return CKAccountStore.shared().primaryAccount
    }

    static func signIn(username: String? = nil, password: String? = nil, systemDialog: Bool = false) throws -> ISStoreAccount {
        guard let username = username, let password = password else { fatalError() }

        var account: ISStoreAccount? = nil
        var error: MASError? = nil

        let accountService: ISAccountService = ISServiceProxy.genericShared().accountService
        let client = ISStoreClient(storeClientType: 0)
        accountService.setStoreClient(client)
        
//        let context = ISAuthenticationContext(accountID: 0)!
//        context.appleIDOverride = username
//
//        if systemDialog {
//            context.appleIDOverride = username
//        } else {
//            context.demoMode = true
//            context.demoAccountName = username
//            context.demoAccountPassword = password
//            context.demoAutologinMode = true
//        }

        let group = DispatchGroup()
        group.enter()

        accountService.account(withAppleID: username) { (storeAccount: ISStoreAccount?) in
            if let _account = storeAccount {
                debugPrint("ISStoreAccount: \(String(describing: _account))")
                _account.password = password
                accountService.add(_account)
//                let response = ISAuthenticationResponse()
//                response.accountIdentifier = username
//                accountService.addAccount(with: response, makePrimary: true) { (storeAccount: ISStoreAccount?) in
//                    if let _account = storeAccount {
//                        account = _account
//                    }
//                }
                account = _account

                let accountStore = CKAccountStore.shared()
                accountStore.addAccount(_account)
                accountStore.signIn()
                debugPrint("ISStoreAccount: \(String(describing: _account))")
            } else {
                // TODO: Handle failed AppleID lookup
                print("No account found for username: \(username)")
            }
            group.leave()
        }
        
//        accountService.signIn(with: context) { success, _account, _error in
//            if success {
//                account = _account
//            } else {
//                error = .signInFailed(error: _error as NSError?)
//            }
//            group.leave()
//        }

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
