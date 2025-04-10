//
//  ISStoreAccount.swift
//  mas
//
//  Created by Andrew Naylor on 22/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit

extension ISStoreAccount {
    static var primaryAccount: ISStoreAccount {
        get throws {
            guard let account = ISServiceProxy.genericShared().storeClient?.primaryAccount else {
                throw MASError.notSignedIn
            }

            return account
        }
    }

    static func signIn(appleID _: String, password _: String, systemDialog _: Bool) throws -> ISStoreAccount {
        // Signing in is no longer possible as of High Sierra.
        // https://github.com/mas-cli/mas/issues/164
        throw MASError.notSupported
    }
}
