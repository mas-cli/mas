//
// Downloader.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

private import CommerceKit

struct Downloader {
	let printer: Printer

	func downloadApp(
		withAppID appID: AppID,
		purchasing: Bool = false,
		withAttemptCount attemptCount: UInt32 = 3
	) async throws {
		do {
			let purchase = await SSPurchase(appID: appID, purchasing: purchasing)
			_ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
				CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
					if let error {
						continuation.resume(throwing: error)
					} else if response?.downloads.isEmpty == false {
						Task {
							do {
								try await PurchaseDownloadObserver(appID: appID, printer: printer).observeDownloadQueue()
								continuation.resume()
							} catch {
								continuation.resume(throwing: error)
							}
						}
					} else {
						continuation.resume(throwing: MASError.noDownloads)
					}
				}
			}
		} catch {
			guard attemptCount > 1 else {
				throw error
			}

			// If the download failed due to network issues, try again. Otherwise, fail immediately.
			guard (error as NSError).domain == NSURLErrorDomain else {
				throw error
			}

			let attemptCount = attemptCount - 1
			printer.warning(
				"Network error (",
				attemptCount,
				attemptCount == 1 ? " attempt remaining):\n" : " attempts remaining):\n",
				error
			)
			try await downloadApp(withAppID: appID, purchasing: purchasing, withAttemptCount: attemptCount)
		}
	}
}
