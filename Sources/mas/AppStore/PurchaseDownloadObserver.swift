//
// PurchaseDownloadObserver.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import CommerceKit
private import Darwin
private import Foundation
private import StoreFoundation

private var downloadingPhaseType: Int64 { 0 }
private var installingPhaseType: Int64 { 1 }
private var initialPhaseType: Int64 { 4 }
private var downloadedPhaseType: Int64 { 5 }

final class PurchaseDownloadObserver: CKDownloadQueueObserver {
	private let adamID: ADAMID
	private let printer: Printer

	private var completionHandler: (() -> Void)?
	private var errorHandler: ((Error) -> Void)?
	private var prevPhaseType: Int64?

	init(adamID: ADAMID, printer: Printer) {
		self.adamID = adamID
		self.printer = printer
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

		if status.isFailed || status.isCancelled {
			queue.removeDownload(withItemIdentifier: adamID)
		} else {
			prevPhaseType = printer.progress(for: metadata.appNameAndVersion, status: status, prevPhaseType: prevPhaseType)
		}
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
		if status.isFailed {
			errorHandler?(status.error ?? MASError.runtimeError("Failed to download \(metadata.appNameAndVersion)"))
		} else if status.isCancelled {
			errorHandler?(MASError.cancelled)
		} else {
			printer.notice("Installed", metadata.appNameAndVersion)
			completionHandler?()
		}
	}
}

private struct ProgressState { // swiftlint:disable:this one_declaration_per_file
	let percentComplete: Float
	let phase: String

	var percentage: String {
		String(format: "%.1f%%", floor(percentComplete * 1000) / 10)
	}
}

private extension SSDownloadMetadata {
	var appNameAndVersion: String {
		"\(title ?? "unknown app") (\(bundleVersion ?? "unknown version"))"
	}
}

private extension Printer {
	func progress(for appNameAndVersion: String, status: SSDownloadStatus, prevPhaseType: Int64?) -> Int64? {
		let currPhaseType = status.activePhase?.phaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case downloadingPhaseType:
				if prevPhaseType == initialPhaseType {
					progressHeader(for: appNameAndVersion, status: status)
				}
			case downloadedPhaseType:
				if prevPhaseType == downloadingPhaseType {
					progressHeader(for: appNameAndVersion, status: status)
				}
			case installingPhaseType:
				progressHeader(for: appNameAndVersion, status: status)
			default:
				break
			}
		}

		if isatty(fileno(stdout)) != 0 {
			// Only output the progress bar if connected to a terminal
			let progressState = status.progressState
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

	private func progressHeader(for appNameAndVersion: String, status: SSDownloadStatus) {
		terminateEphemeral()
		notice(status.activePhaseDescription, appNameAndVersion)
	}
}

private extension SSDownloadStatus {
	var activePhaseDescription: String {
		activePhase?.phaseDescription ?? "Processing"
	}

	var progressState: ProgressState {
		ProgressState(percentComplete: percentComplete, phase: activePhaseDescription)
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
