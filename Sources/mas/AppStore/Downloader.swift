//
// Downloader.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit
private import Foundation
internal import StoreFoundation

struct Downloader {
	let printer: Printer

	func downloadApp(
		withADAMID adamID: ADAMID,
		getting: Bool = false,
		forceDownload: Bool = false, // swiftlint:disable:this function_default_parameter_at_end
		installedApps: [InstalledApp]
	) async throws {
		if !forceDownload, let installedApp = installedApps.first(where: { $0.adamID == adamID }) {
			printer.warning(
				getting ? "Already gotten: " : "Already installed: ",
				installedApp.name,
				" (",
				adamID,
				")",
				separator: ""
			)
			return
		}

		try await downloadApp(withADAMID: adamID, getting: getting)
	}

	func downloadApp(
		withADAMID adamID: ADAMID,
		getting: Bool = false,
		shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool = { _, _ in false },
		withAttemptCount attemptCount: UInt32 = 3
	) async throws {
		do {
			let purchase = await SSPurchase(adamID: adamID, getting: getting)
			_ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
				CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
					if let error {
						continuation.resume(throwing: error)
						return
					}
					guard response?.downloads?.isEmpty == false else {
						continuation.resume(throwing: MASError.noDownloads)
						return
					}

					Task {
						do {
							try await DownloadQueueObserver(adamID: adamID, printer: printer, shouldCancel: shouldCancel)
							.observeDownloadQueue() // swiftformat:disable:this indent
							continuation.resume()
						} catch {
							continuation.resume(throwing: error)
						}
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
				"Network error,",
				attemptCount,
				attemptCount == 1 ? "attempt remaining:" : "attempts remaining:",
				error: error
			)
			try await downloadApp(
				withADAMID: adamID,
				getting: getting,
				shouldCancel: shouldCancel,
				withAttemptCount: attemptCount
			)
		}
	}
}
