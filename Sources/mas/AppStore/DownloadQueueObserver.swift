//
// DownloadQueueObserver.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import CommerceKit
private import CoreFoundation
private import CoreServices
private import Darwin
private import Foundation
private import ObjectiveC
private import StoreFoundation

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
			let fileManager = FileManager.default
			var isDirectory = false as ObjCBool
			guard
				fileManager.fileExists(atPath: downloadFolderURL.path, isDirectory: &isDirectory),
				isDirectory.boolValue
			else {
				return
			}

			let downloadFolderChildURLs = try fileManager
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
						guard resources.isRegularFile == true, let modificationDate = resources.contentModificationDate else {
							return nil
						}

						return (url, modificationDate)
					}
					.max { $0.1 > $1.1 }?
					.0,
					existing: pkgHardLinkURL // swiftformat:enable indent
				)
			} catch {
				MAS.printer.error(error: error)
			}

			receiptHardLinkURL = try hardLinkURL(
				to: downloadFolderChildURLs.first { $0.lastPathComponent == "receipt" },
				existing: receiptHardLinkURL
			)
		} catch {
			MAS.printer.error(error: error)
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

				try manuallyInstall()
			} else {
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

	private func hardLinkURL(to url: URL?, existing existingHardLinkURL: URL?) throws -> URL? {
		guard let url, !url.linksToSameInode(as: existingHardLinkURL) else {
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

	private func manuallyInstall() throws {
		guard pkgHardLinkURL != nil else {
			throw MASError.runtimeError("Failed to find pkg to install")
		}
		guard receiptHardLinkURL != nil else {
			throw MASError.runtimeError("Failed to find receipt to import")
		}

		try spotlightImport(try install())
	}

	private func install() throws -> URL {
		guard let pkgHardLinkPath = pkgHardLinkURL?.path else {
			throw MASError.runtimeError("Failed to find pkg to install")
		}

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/sbin/installer")
		process.arguments = ["-dumplog", "-pkg", pkgHardLinkPath, "-target", "/"]
		let standardOutputPipe = Pipe()
		process.standardOutput = standardOutputPipe
		let standardErrorPipe = Pipe()
		process.standardError = standardErrorPipe
		do {
			try run(asEffectiveUID: 0, andEffectiveGID: 0) { try process.run() }
		} catch {
			throw MASError.runtimeError("Failed to install \(pkgHardLinkPath)", error: error)
		}
		process.waitUntilExit()
		let standardOutputText =
			String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
		let standardErrorText =
			String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
		guard process.terminationStatus == 0 else {
			throw MASError.runtimeError(
				"""
				Failed to install \(pkgHardLinkPath)
				Exit status: \(process.terminationStatus)\(
					standardOutputText.trimmingCharacters(in: .whitespacesAndNewlines).prependIfNotEmpty("\n\nStandard output:\n")
				)\(standardErrorText.trimmingCharacters(in: .whitespacesAndNewlines).prependIfNotEmpty("\n\nStandard error:\n"))
				"""
			)
		}

		let appFolderURLResults =
			appFolderURLRegex.matches(in: standardErrorText, range: NSRange(location: 0, length: standardErrorText.count))
		guard let appFolderURLResult = appFolderURLResults.first else {
			throw MASError.runtimeError(
				"Failed to find app folder URL in installer output",
				error: MASError.runtimeError(standardErrorText)
			)
		}

		let appFolderURLNSRange = appFolderURLResult.range(at: 1)
		guard appFolderURLNSRange.location != NSNotFound else {
			throw MASError.runtimeError(
				"Failed to find app folder URL in installer output",
				error: MASError.runtimeError(standardErrorText)
			)
		}
		guard let appFolderURLRange = Range(appFolderURLNSRange, in: standardErrorText) else {
			throw MASError.runtimeError(
				"Failed to find app folder URL in installer output",
				error: MASError.runtimeError(standardErrorText)
			)
		}

		let appFolderURLString = String(standardErrorText[appFolderURLRange])
		if appFolderURLResults.count > 1 {
			MAS.printer.warning(
				"Found multiple app folder URLs in installer output, using the first:",
				appFolderURLString,
				error: MASError.runtimeError(standardErrorText)
			)
		}
		guard let appFolderURL = URL(string: appFolderURLString) else {
			throw MASError.runtimeError(
				"Failed to parse app folder URL from \(appFolderURLString)",
				error: MASError.runtimeError(standardErrorText)
			)
		}

		return appFolderURL
	}

	private func spotlightImport(_ appFolderURL: URL) throws {
		guard let receiptHardLinkURL else {
			throw MASError.runtimeError("Failed to find receipt to import")
		}
		guard let pkgHardLinkPath = pkgHardLinkURL?.path else {
			throw MASError.runtimeError("Failed to find pkg to install")
		}

		let receiptURL = appFolderURL.appendingPathComponent("Contents/_MASReceipt/receipt")
		do {
			let fileManager = FileManager.default
			try run(asEffectiveUID: 0, andEffectiveGID: 0) {
				try fileManager.createDirectory(at: receiptURL.deletingLastPathComponent(), withIntermediateDirectories: true)
				try fileManager.copyItem(at: receiptHardLinkURL, to: receiptURL)
				try fileManager.setAttributes([.ownerAccountID: 0, .groupOwnerAccountID: 0], ofItemAtPath: receiptURL.path)
			}
		} catch {
			throw MASError.runtimeError(
				"Failed to copy receipt from \(receiptHardLinkURL.path.quoted) to \(receiptURL.path.quoted)",
				error: error
			)
		}

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/bin/mdimport")
		process.arguments = [appFolderURL.path]
		let standardOutputPipe = Pipe()
		process.standardOutput = standardOutputPipe
		let standardErrorPipe = Pipe()
		process.standardError = standardErrorPipe
		do {
			try process.run()
		} catch {
			throw MASError.runtimeError("Failed to install \(pkgHardLinkPath)", error: error)
		}
		process.waitUntilExit()
		guard process.terminationStatus == 0 else {
			throw MASError.runtimeError(
				"""
				Failed to install \(pkgHardLinkPath)
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
	func linksToSameInode(as url: URL?) -> Bool {
		guard let url, url.isFileURL, isFileURL else {
			return false
		}

		do {
			guard
				let fileResourceID1 = try resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
			else {
				MAS.printer.warning("Failed to get file resource identifier for", path)
				return false
			}
			guard
				let fileResourceID2 = try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
			else {
				MAS.printer.warning("Failed to get file resource identifier for", url.path)
				return false
			}

			return fileResourceID1.isEqual(fileResourceID2)
		} catch {
			MAS.printer.warning("Failed to get resource values", error: error)
			return false
		}
	}
}

private func deleteTempFolder(containing url: URL?, fileType: String) {
	guard let url else {
		return
	}

	do {
		try FileManager.default.removeItem(at: url.deletingLastPathComponent())
	} catch {
		MAS.printer.warning("Failed to delete temp folder containing", fileType, url.path, error: error)
	}
}

// swiftlint:disable:next force_try
private let appFolderURLRegex = try! NSRegularExpression(pattern: #"PackageKit: Registered bundle (\S+) for uid 0"#)
