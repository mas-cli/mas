//
// Downloader.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit
private import Foundation
internal import StoreFoundation

func downloadApp(
	withADAMID adamID: ADAMID,
	getting: Bool = false,
	forceDownload: Bool = false, // swiftlint:disable:this function_default_parameter_at_end
	installedApps: [InstalledApp]
) async throws {
	if !forceDownload, let installedApp = installedApps.first(where: { $0.adamID == adamID }) {
		MAS.printer.warning(
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
	shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool = { _, _ in false }
) async throws {
	let purchase = await SSPurchase(adamID: adamID, getting: getting)
	try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
		CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
			if let error {
				continuation.resume(throwing: error)
				return
			}
			guard response?.downloads?.isEmpty == false else {
				continuation.resume(throwing: MASError.runtimeError("No downloads initiated for ADAMID \(adamID)"))
				return
			}

			Task {
				do {
					try await DownloadQueueObserver(adamID: adamID, shouldCancel: shouldCancel).observeDownloadQueue()
					continuation.resume()
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}
}
