//
//  SSPurchase.swift
//  mas-cli
//
//  Created by Andrew Naylor on 25/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import StoreFoundation

typealias SSPurchaseCompletion =
    (_ purchase: SSPurchase?, _ completed: Bool, _ error: Error?, _ response: SSPurchaseResponse?) -> Void

extension SSPurchase {
    func perform(adamId: UInt64, purchase: Bool, _ completion: @escaping SSPurchaseCompletion) {
        var parameters: [String: Any] = [
            "productType": "C",
            "price": 0,
            "salableAdamId": adamId,
            "pg": "default",
            "appExtVrsId": 0,
        ]

        if purchase {
            parameters["macappinstalledconfirmed"] = 1
            parameters["pricingParameters"] = "STDQ"

        } else {
            // is redownload, use existing functionality
            parameters["pricingParameters"] = "STDRDL"
        }

        buyParameters =
            parameters.map { key, value in
                "\(key)=\(value)"
            }
            .joined(separator: "&")

        itemIdentifier = adamId

        if #unavailable(macOS 12) {
            // Monterey obscures the user's App Store account information, but allows
            // redownloads without passing the account to SSPurchase.
            // https://github.com/mas-cli/mas/issues/417
            if let storeAccount = try? ISStoreAccount.primaryAccount.wait() {
                accountIdentifier = storeAccount.dsID
                appleID = storeAccount.identifier
            }
        }

        // Not sure if this is needed, but lets use it here.
        if purchase {
            isRedownload = false
        }

        downloadMetadata = SSDownloadMetadata()
        downloadMetadata.kind = "software"
        downloadMetadata.itemIdentifier = adamId

        CKPurchaseController.shared().perform(self, withOptions: 0, completionHandler: completion)
    }
}
