//
//  SSPurchase.swift
//  mas
//
//  Created by Andrew Naylor on 25/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit

extension SSPurchase {
    func perform(appID: AppID, purchasing: Bool) async throws {
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
        if #unavailable(macOS 12) {
            let storeAccount = try ISStoreAccount.primaryAccount
            accountIdentifier = storeAccount.dsID
            appleID = storeAccount.identifier
        }

        try await perform()
    }

    private func perform() async throws {
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            CKPurchaseController.shared()
                .perform(self, withOptions: 0) { purchase, _, error, response in
                    if let error {
                        continuation.resume(throwing: MASError.purchaseFailed(error: error as NSError))
                    } else if response?.downloads.isEmpty == false, let purchase {
                        Task {
                            do {
                                try await PurchaseDownloadObserver(purchase: purchase).observeDownloadQueue()
                                continuation.resume()
                            } catch {
                                continuation.resume(throwing: MASError.purchaseFailed(error: error as NSError))
                            }
                        }
                    } else {
                        continuation.resume(throwing: MASError.noDownloads)
                    }
                }
        }
    }
}
