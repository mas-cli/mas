//
//  SSPurchase.swift
//  mas
//
//  Created by Andrew Naylor on 25/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit
import StoreFoundation

extension SSPurchase {
    func perform(appID: AppID, purchasing: Bool) -> Promise<Void> {
        var parameters =
            [
                "productType": "C",
                "price": 0,
                "salableAdamId": appID,
                "pg": "default",
                "appExtVrsId": 0,
            ] as [String: Any]

        if purchasing {
            parameters["macappinstalledconfirmed"] = 1
            parameters["pricingParameters"] = "STDQ"
            // Possibly unnecessary…
            isRedownload = false
        } else {
            parameters["pricingParameters"] = "STDRDL"
        }

        buyParameters =
            parameters.map { key, value in
                "\(key)=\(value)"
            }
            .joined(separator: "&")

        itemIdentifier = appID

        downloadMetadata = SSDownloadMetadata()
        downloadMetadata.kind = "software"
        downloadMetadata.itemIdentifier = appID

        // Monterey obscures the user's App Store account, but allows
        // redownloads without passing any account IDs to SSPurchase.
        // https://github.com/mas-cli/mas/issues/417
        if #available(macOS 12, *) {
            return perform()
        }

        return
            ISStoreAccount.primaryAccount
            .then { storeAccount in
                self.accountIdentifier = storeAccount.dsID
                self.appleID = storeAccount.identifier
                return self.perform()
            }
    }

    private func perform() -> Promise<Void> {
        Promise<SSPurchase> { seal in
            CKPurchaseController.shared()
                .perform(self, withOptions: 0) { purchase, _, error, response in
                    if let error {
                        seal.reject(MASError.purchaseFailed(error: error as NSError?))
                        return
                    }

                    guard response?.downloads.isEmpty == false, let purchase else {
                        seal.reject(MASError.noDownloads)
                        return
                    }

                    seal.fulfill(purchase)
                }
        }
        .then { purchase in
            PurchaseDownloadObserver(purchase: purchase).observeDownloadQueue()
        }
    }
}
