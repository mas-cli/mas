//
// PurchaseDownloadObserver.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import CommerceKit

private var downloadingPhaseType: Int64 { 0 }
private var installingPhaseType: Int64 { 1 }
private var initialPhaseType: Int64 { 4 }
private var downloadedPhaseType: Int64 { 5 }

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
			prevPhaseType = download.printProgress(prevPhaseType: prevPhaseType)
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

private extension SSDownload {
	var progressDescription: String {
		"\(metadata.title) (\(metadata.bundleVersion ?? "unknown version"))"
	}

	func printProgress(prevPhaseType: Int64?) -> Int64 {
		let currPhaseType = status.activePhase.phaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case downloadingPhaseType:
				if prevPhaseType == initialPhaseType {
					printProgressHeader()
				}
			case downloadedPhaseType:
				if prevPhaseType == downloadingPhaseType {
					printProgressHeader()
				}
			case installingPhaseType:
				printProgressHeader()
			default:
				break
			}
		}

		if isatty(fileno(stdout)) != 0 {
			// Only display the progress bar if connected to a terminal
			let progressState = status.progressState
			let totalLength = 60
			let completedLength = Int(progressState.percentComplete * Float(totalLength))
			printEphemeral(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				progressState.percentage,
				" ",
				progressState.phase,
				separator: "",
				terminator: ""
			)
		}

		return currPhaseType
	}

	private func printProgressHeader() {
		terminateEphemeralPrinting()
		printNotice(status.activePhase.phaseDescription, progressDescription)
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
		case downloadedPhaseType:
			"Downloaded"
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
