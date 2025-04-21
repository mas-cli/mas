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
}
