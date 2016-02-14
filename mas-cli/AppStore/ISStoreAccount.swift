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
    
    static func signIn(username username: String, password: String) throws -> ISStoreAccount {
        var account: ISStoreAccount? = nil
        var error: NSError? = nil
        
        let accountService = ISServiceProxy.genericSharedProxy().accountService
        let client = ISStoreClient(storeClientType: 0)
        accountService.setStoreClient(client)
        
        let context = ISAuthenticationContext(accountID: 0)
        context.demoMode = true
        context.demoAccountName = username
        context.demoAccountPassword = password
        context.demoAutologinMode = true
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        
        accountService.signInWithContext(context) { success, _account, _error in
            if success {
                account = _account
            } else {
                error = _error
            }
            dispatch_group_leave(group)
        }
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(15) * NSEC_PER_SEC)))
        
        if let account = account {
            return account
        }
        
        throw error ?? MASError(code: .SignInError)
    }
}
