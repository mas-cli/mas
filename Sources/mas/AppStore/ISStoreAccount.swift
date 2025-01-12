//
//  ISStoreAccount.swift
//  mas
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit

private let timeout = 30.0

extension ISStoreAccount {
    static var primaryAccount: Promise<ISStoreAccount> {
        race(
            Promise { seal in
                ISServiceProxy.genericShared().accountService
                    .primaryAccount { storeAccount in
                        seal.fulfill(storeAccount)
                    }
            },
            after(seconds: timeout)
                .then {
                    Promise(error: MASError.notSignedIn)
                }
        )
    }

    static func signIn(appleID _: String, password _: String, systemDialog _: Bool) -> Promise<ISStoreAccount> {
        // Signing in is no longer possible as of High Sierra.
        // https://github.com/mas-cli/mas/issues/164
        Promise(error: MASError.notSupported)
    }
}
