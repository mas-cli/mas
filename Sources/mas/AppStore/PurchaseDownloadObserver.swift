//
// PurchaseDownloadObserver.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import CommerceKit

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
		// Do nothing
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
						terminateEphemeralPrinting()
						printNotice("Downloading", download.progressDescription)
					}
				case downloadedPhaseType:
					if prevPhaseType == downloadingPhaseType {
						terminateEphemeralPrinting()
						printNotice("Downloaded", download.progressDescription)
					}
				case installingPhaseType:
					terminateEphemeralPrinting()
					printNotice("Installing", download.progressDescription)
				default:
					break
				}
				self.prevPhaseType = currPhaseType
			}
			progress(status.progressState)
		}
	}

	func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
		// Do nothing
	}

	func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard
			download.metadata.itemIdentifier == appID,
			let status = download.status
		else {
			return
		}

		terminateEphemeralPrinting()
		if status.isFailed {
			errorHandler?(MASError(downloadFailedError: status.error))
		} else if status.isCancelled {
			errorHandler?(.cancelled)
		} else {
			printNotice("Installed", download.progressDescription)
			completionHandler?()
		}
	}
}

// swiftlint:disable:next one_declaration_per_file
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
	printEphemeral(bar, state.percentage, state.phase, terminator: "")
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
