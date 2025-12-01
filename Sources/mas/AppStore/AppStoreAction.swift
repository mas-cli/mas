//
// AppStoreAction.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import ArgumentParser
private import CommerceKit
internal import StoreFoundation

enum AppStoreAction {
	case get
	case install
	case update

	func apps(withADAMIDs adamIDs: [ADAMID], force: Bool, installedApps: [InstalledApp]) async throws {
		try await apps(
			withADAMIDs: adamIDs.filter { adamID in
				if !force, let installedApp = installedApps.first(where: { $0.adamID == adamID }) {
					MAS.printer.warning(
						self == .get ? "Already gotten: " : "Already installed: ",
						installedApp.name,
						" (",
						adamID,
						")",
						separator: ""
					)
					return false
				}

				return true
			}
		)
	}

	func apps(withADAMIDs adamIDs: [ADAMID]) async throws {
		guard !adamIDs.isEmpty else {
			return
		}
		guard getuid() == 0 else {
			try sudo(MAS._commandName, args: [String(describing: self), "--force"] + adamIDs.map(String.init(describing:)))
			return
		}

		await adamIDs.forEach(attemptTo: "\(self) app for ADAM ID") { adamID in
			try await app(withADAMID: adamID) { _, _ in false }
		}
	}

	func app(withADAMID adamID: ADAMID, shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool) async throws {
		let purchase = await SSPurchase(self, appWithADAMID: adamID)
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
				if let error {
					continuation.resume(throwing: error)
					return
				}
				guard response?.downloads?.isEmpty == false else {
					continuation.resume(throwing: MASError.runtimeError("No downloads initiated for ADAM ID \(adamID)"))
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
}

typealias AppStore = AppStoreAction
