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
	private let printer: Printer

	private var completionHandler: (() -> Void)?
	private var errorHandler: ((Error) -> Void)?
	private var prevPhaseType: Int64?

	init(appID: AppID, printer: Printer) {
		self.appID = appID
		self.printer = printer
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
			prevPhaseType = printer.progress(of: download, prevPhaseType: prevPhaseType)
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

		printer.terminateEphemeral()
		if status.isFailed {
			errorHandler?(status.error)
		} else if status.isCancelled {
			errorHandler?(MASError.cancelled)
		} else {
			printer.notice("Installed", download.progressDescription)
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
}

private extension Printer {
	func progress(of download: SSDownload, prevPhaseType: Int64?) -> Int64 {
		let currPhaseType = download.status.activePhase.phaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case downloadingPhaseType:
				if prevPhaseType == initialPhaseType {
					progressHeader(for: download)
				}
			case downloadedPhaseType:
				if prevPhaseType == downloadingPhaseType {
					progressHeader(for: download)
				}
			case installingPhaseType:
				progressHeader(for: download)
			default:
				break
			}
		}

		if isatty(fileno(stdout)) != 0 {
			// Only output the progress bar if connected to a terminal
			let progressState = download.status.progressState
			let totalLength = 60
			let completedLength = Int(progressState.percentComplete * Float(totalLength))
			ephemeral(
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

	private func progressHeader(for download: SSDownload) {
		terminateEphemeral()
		notice(download.status.activePhase.phaseDescription, download.progressDescription)
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
