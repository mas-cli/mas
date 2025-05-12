//
// Downloader.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

private import CommerceKit

/// Sequentially downloads apps, printing progress to the console.
///
/// Verifies that each supplied app ID is valid before attempting to download.
///
/// - Parameters:
///   - appIDs: The app IDs of the apps to be verified & downloaded.
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
			try await downloadApp(withAppID: appID, purchasing: purchasing, withAttemptCount: 3)
		} catch {
			guard case MASError.unknownAppID = error else {
				throw error
			}
			printWarning(error)
		}
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
		try await downloadApp(withAppID: appID, purchasing: purchasing, withAttemptCount: 3)
	}
}

private func downloadApp(withAppID appID: AppID, purchasing: Bool, withAttemptCount attemptCount: UInt32) async throws {
	do {
		try await downloadApp(withAppID: appID, purchasing: purchasing)
	} catch {
		guard attemptCount > 1 else {
			throw error
		}

		// If the download failed due to network issues, try again. Otherwise, fail immediately.
		guard
			case let MASError.downloadFailed(downloadError) = error,
			downloadError.domain == NSURLErrorDomain
		else {
			throw error
		}

		let attemptCount = attemptCount - 1
		printWarning(downloadError.localizedDescription)
		printWarning("Retrying…", attemptCount, attemptCount == 1 ? "attempt remaining" : "attempts remaining")
		try await downloadApp(withAppID: appID, purchasing: purchasing, withAttemptCount: attemptCount)
	}
}

private func downloadApp(withAppID appID: AppID, purchasing: Bool = false) async throws {
	let purchase = await SSPurchase(appID: appID, purchasing: purchasing)
	_ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
		CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
			if let error {
				continuation.resume(throwing: MASError(purchaseFailedError: error))
			} else if response?.downloads.isEmpty == false {
				Task {
					do {
						try await PurchaseDownloadObserver(appID: appID).observeDownloadQueue()
						continuation.resume()
					} catch {
						continuation.resume(throwing: MASError(purchaseFailedError: error))
					}
				}
			} else {
				continuation.resume(throwing: MASError.noDownloads)
			}
		}
	}
}
