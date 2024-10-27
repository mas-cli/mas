//
//  Downloader.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit
import PromiseKit
import StoreFoundation

/// Downloads a list of apps, one after the other, printing progress to the console.
///
/// - Parameters:
///   - appIDs: The IDs of the apps to be downloaded
///   - purchase: Flag indicating whether the apps needs to be purchased.
///     Only works for free apps. Defaults to false.
/// - Returns: A promise that completes when the downloads are complete. If any fail,
///   the promise is rejected with the first error, after all remaining downloads are attempted.
func downloadAll(_ appIDs: [AppID], purchase: Bool = false) -> Promise<Void> {
    var firstError: Error?
    return
        appIDs
        .reduce(Guarantee.value(())) { previous, appID in
            previous.then {
                downloadWithRetries(appID, purchase: purchase)
                    .recover { error in
                        if firstError == nil {
                            firstError = error
                        }
                    }
            }
        }
        .done {
            if let error = firstError {
                throw error
            }
        }
}

private func downloadWithRetries(_ appID: AppID, purchase: Bool = false, attempts: Int = 3) -> Promise<Void> {
    SSPurchase().perform(appID: appID, purchase: purchase)
        .recover { error in
            guard attempts > 1 else {
                throw error
            }

            // If the download failed due to network issues, try again. Otherwise, fail immediately.
            guard
                case MASError.downloadFailed(let downloadError) = error,
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
