//
//  PurchaseDownloadObserver.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit

private let downloadingPhaseType = 0 as Int64
private let installingPhaseType = 1 as Int64
private let initialPhaseType = 4 as Int64
private let downloadedPhaseType = 5 as Int64

class PurchaseDownloadObserver: CKDownloadQueueObserver {
	private let appID: AppID
	private var completionHandler: (() -> Void)?
	private var errorHandler: ((MASError) -> Void)?
	private var prevPhaseType: Int64?

	init(appID: AppID) {
		self.appID = appID
	}

	deinit {
		// do nothing
	}

	func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
		guard
			download.metadata.itemIdentifier == appID,
			let status = download.status
		else {
			return
		}

		if status.isFailed || status.isCancelled {
			queue.removeDownload(withItemIdentifier: download.metadata.itemIdentifier)
		} else {
			let currPhaseType = status.activePhase.phaseType
			let prevPhaseType = prevPhaseType
			if prevPhaseType != currPhaseType {
				switch currPhaseType {
				case downloadingPhaseType:
					if prevPhaseType == initialPhaseType {
						clearLine()
						printInfo("Downloading", download.progressDescription)
					}
				case downloadedPhaseType:
					if prevPhaseType == downloadingPhaseType {
						clearLine()
						printInfo("Downloaded", download.progressDescription)
					}
				case installingPhaseType:
					clearLine()
					printInfo("Installing", download.progressDescription)
				default:
					break
				}
				self.prevPhaseType = currPhaseType
			}
			progress(status.progressState)
		}
	}

	func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
		// do nothing
	}

	func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard
			download.metadata.itemIdentifier == appID,
			let status = download.status
		else {
			return
		}

		clearLine()
		if status.isFailed {
			errorHandler?(.downloadFailed(error: status.error as NSError))
		} else if status.isCancelled {
			errorHandler?(.cancelled)
		} else {
			printInfo("Installed", download.progressDescription)
			completionHandler?()
		}
	}
}

private struct ProgressState {
	let percentComplete: Float
	let phase: String

	var percentage: String {
		String(format: "%.1f%%", floor(percentComplete * 1000) / 10)
	}
}

private func progress(_ state: ProgressState) {
	// Don't display the progress bar if we're not on a terminal
	guard isatty(fileno(stdout)) != 0 else {
		return
	}

	let barLength = 60
	let completeLength = Int(state.percentComplete * Float(barLength))
	let bar = (0..<barLength).map { $0 < completeLength ? "#" : "-" }.joined()
	clearLine()
	print(bar, state.percentage, state.phase, terminator: "")
	fflush(stdout)
}

private extension SSDownload {
	var progressDescription: String {
		"\(metadata.title) (\(metadata.bundleVersion ?? "unknown version"))"
	}
}

private extension SSDownloadStatus {
	var progressState: ProgressState {
		ProgressState(percentComplete: percentComplete, phase: activePhase.phaseDescription)
	}
}

private extension SSDownloadPhase {
	var phaseDescription: String {
		switch phaseType {
		case downloadingPhaseType:
			"Downloading"
		case installingPhaseType:
			"Installing"
		default:
			"Waiting"
		}
	}
}

extension PurchaseDownloadObserver {
	func observeDownloadQueue(_ downloadQueue: CKDownloadQueue = .shared()) async throws {
		let observerID = downloadQueue.add(self)
		defer {
			downloadQueue.remove(observerID)
		}

		try await withCheckedThrowingContinuation { continuation in
			completionHandler = {
				self.completionHandler = nil
				self.errorHandler = nil
				continuation.resume()
			}
			errorHandler = { error in
				self.completionHandler = nil
				self.errorHandler = nil
				continuation.resume(throwing: error)
			}
		}
	}
}
