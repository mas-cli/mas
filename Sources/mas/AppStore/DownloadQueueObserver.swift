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
	private let printer: Printer
	private let shouldCancel: (SSDownload, Bool) -> Bool

	private var completionHandler: (() -> Void)?
	private var errorHandler: ((any Error) -> Void)?
	private var prevPhaseType: Int64?

	init(
		adamID: ADAMID,
		printer: Printer,
		shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool = { _, _ in false }
	) {
		self.adamID = adamID
		self.printer = printer
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
					printer.progressHeader(for: appNameAndVersion, status: status)
				}
			case downloadedPhaseType:
				if prevPhaseType == downloadingPhaseType {
					printer.progressHeader(for: appNameAndVersion, status: status)
				}
			case installingPhaseType:
				printer.progressHeader(for: appNameAndVersion, status: status)
			default:
				break
			}
		}

		if isatty(FileHandle.standardOutput.fileDescriptor) != 0 {
			// Only output the progress bar if connected to a terminal
			let percentComplete = status.percentComplete
			let totalLength = 60
			let completedLength = Int(percentComplete * Float(totalLength))
			printer.ephemeral(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				String(format: "%.1f%%", floor(percentComplete * 1000) / 10),
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

		printer.terminateEphemeral()

		guard !status.isFailed else {
			errorHandler?(status.error ?? MASError.runtimeError("Failed to download \(metadata.appNameAndVersion)"))
			return
		}
		guard !status.isCancelled else {
			guard shouldCancel(download, false) else {
				errorHandler?(MASError.cancelled)
				return
			}

			completionHandler?()
			return
		}

		printer.notice("Installed", metadata.appNameAndVersion)
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

private extension SSDownloadMetadata {
	var appNameAndVersion: String {
		"\(title ?? "unknown app") (\(bundleVersion ?? "unknown version"))"
	}
}

private extension Printer {
	func progressHeader(for appNameAndVersion: String, status: SSDownloadStatus) {
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

private let downloadingPhaseType = 0 as Int64
private let installingPhaseType = 1 as Int64
private let initialPhaseType = 4 as Int64
private let downloadedPhaseType = 5 as Int64
