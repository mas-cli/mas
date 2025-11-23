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

		let currPhaseType = status.activePhaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case .downloading:
				if prevPhaseType == .initial {
					MAS.printer.progress(phase: currPhaseType, for: metadata.appNameAndVersion)
				}
			case .downloaded:
				if prevPhaseType == .downloading {
					MAS.printer.progress(phase: currPhaseType, for: metadata.appNameAndVersion)
				}
			case .installing:
				MAS.printer.progress(phase: currPhaseType, for: metadata.appNameAndVersion)
			default:
				break
			}
		}

		let percentComplete = status.phasePercentComplete
		if isatty(FileHandle.standardOutput.fileDescriptor) != 0, percentComplete != 0 || currPhaseType != .initial {
			// Output the progress bar iff connected to a terminal
			let totalLength = 60
			let completedLength = Int(percentComplete * Float(totalLength))
			MAS.printer.clearCurrentLine(of: .standardOutput)
			MAS.printer.info(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				String(format: "%.0f%%", floor(percentComplete * 100).rounded()),
				" ",
				status.activePhaseType.description,
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

		MAS.printer.clearCurrentLine(of: .standardOutput)

		do {
			if let error = status.error {
				throw error
			}
			guard !status.isFailed else {
				throw MASError.runtimeError("Failed to download \(metadata.appNameAndVersion)")
			}
			guard !status.isCancelled else {
				guard shouldCancel(download, false) else {
					throw MASError.runtimeError("Download cancelled")
				}

				completionHandler?()
				return
			}

			MAS.printer.notice("Installed", metadata.appNameAndVersion)
			completionHandler?()
		} catch {
			errorHandler?(error)
		}
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

private enum PhaseType: Int64 { // swiftlint:disable sorted_enum_cases
	case initial = 4 // swiftlint:disable:previous one_declaration_per_file
	case downloading = 0
	case downloaded = 5
	case installing = 1 // swiftlint:enable sorted_enum_cases
}

extension PhaseType: CustomStringConvertible {
	var description: String {
		switch self {
		case .downloading:
			"Downloading"
		case .downloaded:
			"Downloaded"
		case .installing:
			"Installing"
		default:
			"Waiting"
		}
	}
}

private extension PhaseType? {
	var description: String {
		map(\.description) ?? "Processing"
	}
}

private extension Printer {
	func progress(phase: PhaseType?, for appNameAndVersion: String) {
		clearCurrentLine(of: .standardOutput)
		notice(phase.description, appNameAndVersion)
	}
}

private extension SSDownloadMetadata {
	var appNameAndVersion: String {
		"\(title ?? "unknown app") (\(bundleVersion ?? "unknown version"))"
	}
}

private extension SSDownloadStatus {
	var activePhaseType: PhaseType? {
		activePhase.flatMap { PhaseType(rawValue: $0.phaseType) }
	}
}
