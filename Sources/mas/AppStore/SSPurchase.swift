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
    func perform(adamId: AppID, purchase: Bool) -> Promise<Void> {
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
            parameters["pricingParameters"] = "STDRDL"
        }

        buyParameters =
            parameters.map { key, value in
                "\(key)=\(value)"
            }
            .joined(separator: "&")

        itemIdentifier = adamId

        // Not sure if this is needed…
        if purchase {
            isRedownload = false
        }

        downloadMetadata = SSDownloadMetadata()
        downloadMetadata.kind = "software"
        downloadMetadata.itemIdentifier = adamId

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
            CKPurchaseController.shared().perform(self, withOptions: 0) { purchase, _, error, response in
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
            let observer = PurchaseDownloadObserver(purchase: purchase)
            let downloadQueue = CKDownloadQueue.shared()
            let observerID = downloadQueue.add(observer)

            return Promise<Void> { seal in
                observer.errorHandler = seal.reject
                observer.completionHandler = seal.fulfill_
            }
            .ensure {
                downloadQueue.remove(observerID)
            }
        }
    }
}
