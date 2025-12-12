//
// DownloadQueueObserver.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import CommerceKit
private import Foundation
private import ObjectiveC
internal import StoreFoundation

final class DownloadQueueObserver: CKDownloadQueueObserver {
	private let adamID: ADAMID
	private let shouldCancel: (SSDownload, Bool) -> Bool
	private let downloadFolderURL: URL

	private var completionHandler: (() -> Void)?
	private var errorHandler: ((any Error) -> Void)?
	private var prevPhaseType: PhaseType?
	private var pkgHardLinkURL: URL?
	private var receiptHardLinkURL: URL?

	init(adamID: ADAMID, shouldCancel: @Sendable @escaping (SSDownload, Bool) -> Bool = { _, _ in false }) {
		self.adamID = adamID
		self.shouldCancel = shouldCancel
		downloadFolderURL = URL(fileURLWithPath: "\(CKDownloadDirectory(nil))/\(adamID)", isDirectory: true)
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

		do {
			let downloadFolderChildURLs = try FileManager.default
			.contentsOfDirectory( // swiftformat:disable indent
				at: downloadFolderURL,
				includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey]
			)

			do { // swiftformat:enable indent
				pkgHardLinkURL = try hardLinkURL(
					to: try downloadFolderChildURLs
					.compactMap { url -> (URL, Date)? in // swiftformat:disable indent
						guard url.pathExtension == "pkg" else {
							return nil
						}

						let resources = try url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
						return resources.isRegularFile == true ? resources.contentModificationDate.map { (url, $0) } : nil
					}
					.max { $0.1 > $1.1 }?
					.0,
					existing: pkgHardLinkURL // swiftformat:enable indent
				)
			} catch {
				MAS.printer.warning("Failed to link pkg for", metadata.appNameAndVersion, error: error)
			}

			do {
				receiptHardLinkURL = try hardLinkURL(
					to: downloadFolderChildURLs.first { $0.lastPathComponent == "receipt" },
					existing: receiptHardLinkURL
				)
			} catch {
				MAS.printer.warning("Failed to link receipt for", metadata.appNameAndVersion, error: error)
			}
		} catch {
			MAS.printer.warning(
				"Failed to read contents of download folder",
				downloadFolderURL.path.quoted,
				"for",
				metadata.appNameAndVersion,
				error: error
			)
		}

		let currPhaseType = status.activePhaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case .downloading:
				if prevPhaseType == .initial {
					MAS.printer.progress(phaseType: currPhaseType, for: metadata.appNameAndVersion)
				}
			case .downloaded:
				if prevPhaseType == .downloading {
					MAS.printer.progress(phaseType: currPhaseType, for: metadata.appNameAndVersion)
				}
			case .installing:
				MAS.printer.progress(phaseType: currPhaseType, for: metadata.appNameAndVersion)
			default:
				break
			}
		}

		let percentComplete = status.phasePercentComplete
		if FileHandle.standardOutput.isTerminal, percentComplete != 0 || currPhaseType != .initial {
			// Output the progress bar iff connected to a terminal
			let totalLength = 60
			let completedLength = Int(percentComplete * Float(totalLength))
			MAS.printer.clearCurrentLine(of: .standardOutput)
			MAS.printer.info(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				UInt64((percentComplete * 100).rounded()),
				"% ",
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

		defer {
			deleteTempFolder(containing: pkgHardLinkURL, fileType: "pkg")
			deleteTempFolder(containing: receiptHardLinkURL, fileType: "receipt")
		}

		MAS.printer.clearCurrentLine(of: .standardOutput)

		do {
			if let error = status.error as? NSError {
				guard error.domain == "PKInstallErrorDomain", error.code == 201 else {
					throw error
				}

				try install(appNameAndVersion: metadata.appNameAndVersion)
			} else {
				guard !status.isFailed else {
					throw MASError.error("Failed to download \(metadata.appNameAndVersion)")
				}
				guard !status.isCancelled else {
					guard shouldCancel(download, false) else {
						throw MASError.error("Download cancelled for \(metadata.appNameAndVersion)")
					}

					completionHandler?()
					return
				}
			}

			MAS.printer.notice("Installed", metadata.appNameAndVersion)
			completionHandler?()
		} catch {
			errorHandler?(error)
		}
	}

	func observeDownloadQueue(_ queue: CKDownloadQueue = .shared()) async throws {
		let observerUUID = queue.add(self)
		defer {
			queue.removeObserver(observerUUID)
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

	private func hardLinkURL(to url: URL?, existing existingHardLinkURL: URL?) throws -> URL? {
		guard let url, !(try url.linksToSameInode(as: existingHardLinkURL)) else {
			return existingHardLinkURL
		}

		let fileManager = FileManager.default
		let hardLinkURL = try fileManager.url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: fileManager.homeDirectoryForCurrentUser,
			create: true
		)
		.appendingPathComponent("\(adamID)-\(url.lastPathComponent)", isDirectory: false)
		try fileManager.linkItem(at: url, to: hardLinkURL)
		return hardLinkURL
	}

	private func install(appNameAndVersion: String) throws {
		guard let receiptHardLinkURL else {
			throw MASError.error("Failed to find receipt to import for \(appNameAndVersion)")
		}
		guard let pkgHardLinkPath = pkgHardLinkURL?.path else {
			throw MASError.error("Failed to find pkg to install for \(appNameAndVersion)")
		}

		let appFolderURL = try installPkg(appNameAndVersion: appNameAndVersion)
		let receiptURL = appFolderURL.appendingPathComponent("Contents/_MASReceipt/receipt", isDirectory: false)
		do {
			let fileManager = FileManager.default
			try run(asEffectiveUID: 0, andEffectiveGID: 0) {
				try fileManager.createDirectory(at: receiptURL.deletingLastPathComponent(), withIntermediateDirectories: true)
				try fileManager.copyItem(at: receiptHardLinkURL, to: receiptURL)
				try fileManager.setAttributes([.ownerAccountID: 0, .groupOwnerAccountID: 0], ofItemAtPath: receiptURL.path)
			}
		} catch {
			throw MASError.error(
				"""
				Failed to copy receipt for \(appNameAndVersion) from \(receiptHardLinkURL.path.quoted) to\
				 \(receiptURL.path.quoted)
				""",
				error: error
			)
		}

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/bin/mdimport", isDirectory: false)
		process.arguments = [appFolderURL.path]
		let standardOutputPipe = Pipe()
		process.standardOutput = standardOutputPipe
		let standardErrorPipe = Pipe()
		process.standardError = standardErrorPipe
		do {
			try process.run()
		} catch {
			throw MASError.error("Failed to install \(appNameAndVersion) from \(pkgHardLinkPath)", error: error)
		}
		process.waitUntilExit()
		guard process.terminationStatus == 0 else {
			throw MASError.error(
				"""
				Failed to install \(appNameAndVersion) from \(pkgHardLinkPath)
				Exit status: \(process.terminationStatus)\(
					String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
					.trimmingCharacters(in: .whitespacesAndNewlines) // swiftformat:disable indent
					.prependIfNotEmpty("\n\nStandard output:\n") ?? ""
				)\(String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
					.trimmingCharacters(in: .whitespacesAndNewlines)
					.prependIfNotEmpty("\n\nStandard error:\n") ?? "" // swiftformat:enable indent
				)
				"""
			)
		}
	}

	private func installPkg(appNameAndVersion: String) throws -> URL {
		guard let pkgHardLinkPath = pkgHardLinkURL?.path else {
			throw MASError.error("Failed to find pkg to install for \(appNameAndVersion)")
		}

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/sbin/installer", isDirectory: false)
		process.arguments = ["-dumplog", "-pkg", pkgHardLinkPath, "-target", "/"]
		let standardOutputPipe = Pipe()
		process.standardOutput = standardOutputPipe
		let standardErrorPipe = Pipe()
		process.standardError = standardErrorPipe
		do {
			try run(asEffectiveUID: 0, andEffectiveGID: 0) { try process.run() }
		} catch {
			throw MASError.error("Failed to install \(appNameAndVersion) from \(pkgHardLinkPath)", error: error)
		}
		process.waitUntilExit()
		let standardOutputText =
			String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
		let standardErrorText =
			String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
		guard process.terminationStatus == 0 else {
			throw MASError.error(
				"""
				Failed to install \(appNameAndVersion) from \(pkgHardLinkPath)
				Exit status: \(process.terminationStatus)\(
					standardOutputText.trimmingCharacters(in: .whitespacesAndNewlines).prependIfNotEmpty("\n\nStandard output:\n")
				)\(standardErrorText.trimmingCharacters(in: .whitespacesAndNewlines).prependIfNotEmpty("\n\nStandard error:\n"))
				"""
			)
		}
		guard
			let appFolderURLResult = appFolderURLRegex // swiftformat:disable indent
			.firstMatch(in: standardErrorText, range: NSRange(location: 0, length: standardErrorText.count)),
			let appFolderURLNSRange = appFolderURLResult.range(at: 1) as NSRange?,
			appFolderURLNSRange.location != NSNotFound,
			let appFolderURLRange = Range(appFolderURLNSRange, in: standardErrorText)
		else { // swiftformat:enable indent
			throw MASError.error(
				"Failed to find app folder URL in installer output for \(appNameAndVersion)",
				error: standardErrorText
			)
		}

		let appFolderURLString = String(standardErrorText[appFolderURLRange])
		guard let appFolderURL = URL(string: appFolderURLString) else {
			throw MASError.error(
				"Failed to parse app folder URL for \(appNameAndVersion) from \(appFolderURLString)",
				error: standardErrorText
			)
		}

		return appFolderURL
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
	func progress(phaseType: PhaseType?, for appNameAndVersion: String) {
		clearCurrentLine(of: .standardOutput)
		notice(phaseType.description, appNameAndVersion)
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

private extension String {
	func prependIfNotEmpty(_ prefix: String) -> Self {
		isEmpty ? self : prefix + self
	}
}

private extension URL {
	func linksToSameInode(as url: URL?) throws -> Bool {
		guard let url, url.isFileURL, isFileURL else {
			return false
		}
		guard let fileResourceID1 = try resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(path)")
		}
		guard
			let fileResourceID2 = try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
		else {
			throw MASError.error("Failed to get file resource identifier for \(url.path)")
		}

		return fileResourceID1.isEqual(fileResourceID2)
	}
}

private func deleteTempFolder(containing url: URL?, fileType: String) {
	url.map { url in
		do {
			try FileManager.default.removeItem(at: url.deletingLastPathComponent())
		} catch {
			MAS.printer.warning("Failed to delete temp folder containing", fileType, url.path, error: error)
		}
	}
}

// swiftlint:disable:next force_try
private let appFolderURLRegex = try! NSRegularExpression(pattern: #"PackageKit: Registered bundle (\S+) for uid 0"#)
