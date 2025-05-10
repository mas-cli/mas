//
// Downloader.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit

struct Downloader {
	let printer: Printer

	func downloadApps(
		withAppIDs appIDs: [AppID],
		purchasing: Bool,
		forceDownload: Bool,
		installedApps: [InstalledApp],
		searcher: AppStoreSearcher
	) async {
		for appID in appIDs.filter({ appID in
			if let installedApp = installedApps.first(where: { appID.matches($0) }), !forceDownload {
				printer.warning(
					purchasing ? "Already purchased: " : "Already installed: ",
					installedApp.name,
					" (",
					appID,
					")",
					separator: ""
				)
				return false
			}
			return true
		}) {
			do {
				try await downloadApp(withADAMID: try await appID.adamID(searcher: searcher), purchasing: purchasing)
			} catch {
				printer.error(error: error)
			}
		}
	}

	func downloadApp(
		withADAMID adamID: ADAMID,
		purchasing: Bool = false,
		withAttemptCount attemptCount: UInt32 = 3
	) async throws {
		do {
			let purchase = await SSPurchase(adamID: adamID, purchasing: purchasing)
			_ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
				CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
					if let error {
						continuation.resume(throwing: error)
					} else if response?.downloads?.isEmpty == false {
						Task {
							do {
								try await PurchaseDownloadObserver(adamID: adamID, printer: printer).observeDownloadQueue()
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
				error,
				separator: ""
			)
			try await downloadApp(withADAMID: adamID, purchasing: purchasing, withAttemptCount: attemptCount)
		}
	}
}
