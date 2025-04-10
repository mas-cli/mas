//
//  Downloader.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import StoreFoundation

/// Sequentially downloads apps, printing progress to the console.
///
/// Verifies that each supplied app ID is valid before attempting to download.
///
/// - Parameters:
///   - appIDs: The app IDs of the apps to be verified and downloaded.
///   - searcher: The `AppStoreSearcher` used to verify app IDs.
///   - purchasing: Flag indicating if the apps will be purchased. Only works for free apps. Defaults to false.
/// - Throws: If any download fails, immediately throws an error.
func downloadApps(
    withAppIDs appIDs: [AppID],
    verifiedBy searcher: AppStoreSearcher,
    purchasing: Bool = false
) async throws {
    for appID in appIDs {
        do {
            _ = try await searcher.lookup(appID: appID)
        } catch {
            guard case MASError.unknownAppID = error else {
                throw error
            }

            printWarning("App ID \(appID) not found in Mac App Store.")
            continue
        }
        try await downloadApp(withAppID: appID, purchasing: purchasing)
    }
}

/// Sequentially downloads apps, printing progress to the console.
///
/// - Parameters:
///   - appIDs: The app IDs of the apps to be downloaded.
///   - purchasing: Flag indicating if the apps will be purchased. Only works for free apps. Defaults to false.
/// - Throws: If a download fails, immediately throws an error.
func downloadApps(withAppIDs appIDs: [AppID], purchasing: Bool = false) async throws {
    for appID in appIDs {
        try await downloadApp(withAppID: appID, purchasing: purchasing)
    }
}

private func downloadApp(
    withAppID appID: AppID,
    purchasing: Bool = false,
    withAttemptCount attemptCount: UInt32 = 3
) async throws {
    do {
        try await SSPurchase().perform(appID: appID, purchasing: purchasing)
    } catch {
        guard attemptCount > 1 else {
            throw error
        }

        // If the download failed due to network issues, try again. Otherwise, fail immediately.
        guard
            case MASError.downloadFailed(let downloadError) = error,
            case NSURLErrorDomain = downloadError?.domain
        else {
            throw error
        }

        let attemptCount = attemptCount - 1
        printWarning((downloadError ?? error).localizedDescription)
        printWarning("Trying again up to \(attemptCount) more \(attemptCount == 1 ? "time" : "times").")
        try await downloadApp(withAppID: appID, purchasing: purchasing, withAttemptCount: attemptCount)
    }
}
