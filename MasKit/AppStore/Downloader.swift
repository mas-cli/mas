//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import StoreFoundation

/// Monitors app download progress.
///
/// - Parameter adamId: An app ID?
/// - Parameter purchase: Flag indicating whether the app needs to be purchased.
/// Only works for free apps. Defaults to false.
/// - Returns: An error, if one occurred.
func download(_ adamId: UInt64, purchase: Bool = false) -> MASError? {
    guard let account = ISStoreAccount.primaryAccount else {
        return .notSignedIn
    }

    guard let storeAccount = account as? ISStoreAccount
    else { fatalError("Unable to cast StoreAccount to ISStoreAccount") }
    let purchase = SSPurchase(adamId: adamId, account: storeAccount, purchase: purchase)

    var purchaseError: MASError?
    var observerIdentifier: CKDownloadQueueObserver?

    let group = DispatchGroup()
    group.enter()
    purchase.perform { purchase, _, error, response in
        if let error = error {
            purchaseError = .purchaseFailed(error: error as NSError?)
            group.leave()
            return
        }

        if let downloads = response?.downloads, downloads.count > 0, let purchase = purchase {
            let observer = PurchaseDownloadObserver(purchase: purchase)

            observer.errorHandler = { error in
                purchaseError = error
                group.leave()
            }

            observer.completionHandler = {
                group.leave()
            }

            let downloadQueue = CKDownloadQueue.shared()
            observerIdentifier = downloadQueue.add(observer)
        } else {
            print("No downloads")
            purchaseError = .noDownloads
            group.leave()
        }
    }

    _ = group.wait(timeout: .distantFuture)

    if let observerIdentifier = observerIdentifier {
        CKDownloadQueue.shared().remove(observerIdentifier)
    }

    return purchaseError
}
