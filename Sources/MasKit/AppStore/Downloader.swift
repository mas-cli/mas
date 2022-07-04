//
//  Downloader.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit
import StoreFoundation

/// Downloads a list of apps, one after the other, printing progress to the console.
///
/// - Parameter appIDs: The IDs of the apps to be downloaded
/// - Parameter purchase: Flag indicating whether the apps needs to be purchased.
/// Only works for free apps. Defaults to false.
/// - Returns: A promise that completes when the downloads are complete. If any fail,
/// the promise is rejected with the first error, after all remaining downloads are attempted.
func downloadAll(_ appIDs: [UInt64], purchase: Bool = false) -> Promise<Void> {
    var firstError: Error?
    return appIDs.reduce(Guarantee<Void>.value(())) { previous, appID in
        previous.then {
            downloadWithRetries(appID, purchase: purchase).recover { error in
                if firstError == nil {
                    firstError = error
                }
            }
        }
    }.done {
        if let error = firstError {
            throw error
        }
    }
}

private func downloadWithRetries(
    _ appID: UInt64, purchase: Bool = false, attempts: Int = 3
) -> Promise<Void> {
    download(appID, purchase: purchase).recover { error -> Promise<Void> in
        guard attempts > 1 else {
            throw error
        }

        // If the download failed due to network issues, try again. Otherwise, fail immediately.
        guard case MASError.downloadFailed(let downloadError) = error,
            case NSURLErrorDomain = downloadError?.domain
        else {
            throw error
        }

        let attempts = attempts - 1
        printWarning((downloadError ?? error).localizedDescription)
        printWarning("Trying again up to \(attempts) more \(attempts == 1 ? "time" : "times").")
        return downloadWithRetries(appID, purchase: purchase, attempts: attempts)
    }
}

/// Downloads an app, printing progress to the console.
///
/// - Parameter appID: The ID of the app to be downloaded
/// - Parameter purchase: Flag indicating whether the app needs to be purchased.
/// Only works for free apps. Defaults to false.
/// - Returns: A promise the completes when the download is complete.
private func download(_ appID: UInt64, purchase: Bool = false) -> Promise<Void> {
    var storeAccount: ISStoreAccount?
    if #unavailable(macOS 12) {
        // Monterey obscured the user's account information, but still allows
        // redownloads without passing it to SSPurchase.
        // https://github.com/mas-cli/mas/issues/417
        guard let account = ISStoreAccount.primaryAccount else {
            return Promise(error: MASError.notSignedIn)
        }

        storeAccount = account as? ISStoreAccount
        guard storeAccount != nil else {
            fatalError("Unable to cast StoreAccount to ISStoreAccount")
        }
    }

    return Promise<SSPurchase> { seal in
        let purchase = SSPurchase(adamId: appID, account: storeAccount, purchase: purchase)
        purchase.perform { purchase, _, error, response in
            if let error = error {
                seal.reject(MASError.purchaseFailed(error: error as NSError?))
                return
            }

            guard response?.downloads.isEmpty == false, let purchase = purchase else {
                print("No downloads")
                seal.reject(MASError.noDownloads)
                return
            }

            seal.fulfill(purchase)
        }
    }.then { purchase -> Promise<Void> in
        let observer = PurchaseDownloadObserver(purchase: purchase)
        let download = Promise<Void> { seal in
            observer.errorHandler = seal.reject
            observer.completionHandler = seal.fulfill_
        }

        let downloadQueue = CKDownloadQueue.shared()
        let observerID = downloadQueue.add(observer)
        return download.ensure {
            downloadQueue.remove(observerID)
        }
    }
}
