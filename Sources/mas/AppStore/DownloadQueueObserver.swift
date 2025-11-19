//
// DownloadQueueObserver.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import CommerceKit
private import Darwin
private import Foundation
private import StoreFoundation

final class DownloadQueueObserver: CKDownloadQueueObserver {
	private let adamID: ADAMID
	private let shouldCancel: (SSDownload, Bool) -> Bool

	private var completionHandler: (() -> Void)?
	private var errorHandler: ((any Error) -> Void)?
	private var prevPhaseType: PhaseType?

	init(adamID: ADAMID, shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool = { _, _ in false }) {
		self.adamID = adamID
		self.shouldCancel = shouldCancel
	}

	deinit {
		// Do nothing
	}

	func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
		guard
			let metadata = download.metadata,
			metadata.itemIdentifier == adamID,
			let status = download.status
		else {
			return
		}
		guard !status.isCancelled, !status.isFailed else {
			queue.removeDownload(withItemIdentifier: adamID)
			return
		}
		guard !shouldCancel(download, true) else {
			queue.cancelDownload(download, promptToConfirm: false, askToDelete: false)
			return
		}

		let appNameAndVersion = metadata.appNameAndVersion
		let currPhaseType = status.activePhase?.phaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case downloadingPhaseType:
				if prevPhaseType == initialPhaseType {
					MAS.printer.progress(status: status, for: appNameAndVersion)
				}
			case downloadedPhaseType:
				if prevPhaseType == downloadingPhaseType {
					MAS.printer.progress(status: status, for: appNameAndVersion)
				}
			case installingPhaseType:
				MAS.printer.progress(status: status, for: appNameAndVersion)
			default:
				break
			}
		}

		if isatty(FileHandle.standardOutput.fileDescriptor) != 0 {
			// Only output the progress bar if connected to a terminal
			let percentComplete = min(
				status.percentComplete / (currPhaseType == downloadingPhaseType ? 0.8 : 0.2),
				1.0
			)
			let totalLength = 60
			let completedLength = Int(percentComplete * Float(totalLength))
			MAS.printer.ephemeral(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				String(format: "%.0f%%", floor(percentComplete * 100).rounded()),
				" ",
				status.activePhaseDescription,
				separator: "",
				terminator: ""
			)
		}

		prevPhaseType = currPhaseType
	}

	func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
		// Do nothing
	}

	func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard
			let metadata = download.metadata,
			metadata.itemIdentifier == adamID,
			let status = download.status
		else {
			return
		}

		MAS.printer.terminateEphemeral()

		guard !status.isFailed else {
			errorHandler?(status.error ?? MASError.runtimeError("Failed to download \(metadata.appNameAndVersion)"))
			return
		}
		guard !status.isCancelled else {
			shouldCancel(download, false) ? completionHandler?() : errorHandler?(MASError.runtimeError("Download cancelled"))
			return
		}

		MAS.printer.notice("Installed", metadata.appNameAndVersion)
		completionHandler?()
	}

	func observeDownloadQueue(_ queue: CKDownloadQueue = .shared()) async throws {
		let observerID = queue.add(self)
		defer {
			queue.removeObserver(observerID)
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

private typealias PhaseType = Int64

private extension SSDownloadMetadata {
	var appNameAndVersion: String {
		"\(title ?? "unknown app") (\(bundleVersion ?? "unknown version"))"
	}
}

private extension Printer {
	func progress(status: SSDownloadStatus, for appNameAndVersion: String) {
		terminateEphemeral()
		notice(status.activePhaseDescription, appNameAndVersion)
	}
}

private extension SSDownloadStatus {
	var activePhaseDescription: String {
		switch activePhase?.phaseType {
		case downloadedPhaseType:
			"Downloaded"
		case downloadingPhaseType:
			"Downloading"
		case installingPhaseType:
			"Installing"
		case nil:
			"Processing"
		default:
			"Waiting"
		}
	}
}

private let downloadingPhaseType = 0 as PhaseType
private let installingPhaseType = 1 as PhaseType
private let initialPhaseType = 4 as PhaseType
private let downloadedPhaseType = 5 as PhaseType
