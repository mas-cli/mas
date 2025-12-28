//
// AppStoreAction+download.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit
private import CoreServices
private import Foundation
private import ObjectiveC
private import StoreFoundation

extension AppStoreAction { // swiftlint:disable:this file_types_order
	@MainActor
	func app(withADAMID adamID: ADAMID, shouldCancel: @Sendable @escaping (String?, Bool) -> Bool) async throws {
		let purchase = SSPurchase(
			buyParameters: """
				productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
				\(self == .get ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
				""",
		)

		// Possibly unnecessary…
		purchase.isRedownload = self != .get
		purchase.isUpdate = self == .update

		purchase.itemIdentifier = adamID

		let downloadMetadata = SSDownloadMetadata(kind: "software")
		downloadMetadata.itemIdentifier = adamID
		purchase.downloadMetadata = downloadMetadata

		let queue = CKDownloadQueue.shared()
		let observer = DownloadQueueObserver(for: self, of: adamID, shouldCancel: shouldCancel)
		let observerUUID = queue.add(observer)
		defer {
			queue.removeObserver(observerUUID)
		}

		try await withCheckedThrowingContinuation { continuation in
			observer.set(continuation: continuation)

			CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
				if let error {
					Task {
						await observer.resumeOnce { $0.resume(throwing: error) }
					}
				} else if response?.downloads?.isEmpty != false {
					Task {
						await observer.resumeOnce { continuation in
							continuation.resume(throwing: MASError.error("No downloads initiated for ADAM ID \(adamID)"))
						}
					}
				}
			}
		}
	}
}

private actor DownloadQueueObserver: CKDownloadQueueObserver {
	private let action: AppStoreAction
	private let adamID: ADAMID
	private let shouldCancel: @Sendable (String?, Bool) -> Bool
	private let downloadFolderURL: URL

	private nonisolated(unsafe) var continuation = CheckedContinuation<Void, any Error>?.none

	private var prevPhaseType = PhaseType.processing
	private var pkgHardLinkURL = URL?.none
	private var receiptHardLinkURL = URL?.none
	private var alreadyResumed = false

	init(for action: AppStoreAction, of adamID: ADAMID, shouldCancel: @Sendable @escaping (String?, Bool) -> Bool) {
		self.action = action
		self.adamID = adamID
		self.shouldCancel = shouldCancel
		downloadFolderURL = URL(filePath: "\(CKDownloadDirectory(nil))/\(adamID)", directoryHint: .isDirectory)
	}

	deinit {
		resumeOnce(
			alreadyResumed: alreadyResumed,
			pkgHardLinkURL: pkgHardLinkURL,
			receiptHardLinkURL: receiptHardLinkURL,
		) { continuation in
			continuation // swiftformat:disable:next indent
			.resume(throwing: MASError.error("Observer deallocated before download completed for ADAM ID \(adamID)"))
		}
	}

	nonisolated func set(continuation: CheckedContinuation<Void, any Error>) {
		unsafe self.continuation = continuation
	}

	nonisolated func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
		// Do nothing
	}

	nonisolated func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
		guard
			let snapshot = DownloadSnapshot(to: action, download),
			snapshot.adamID == adamID,
			!snapshot.isCancelled,
			!snapshot.isFailed
		else {
			return
		}
		guard !shouldCancel(snapshot.version, true) else {
			queue.cancelDownload(download, promptToConfirm: false, askToDelete: false)
			return
		}

		Task {
			await statusChanged(for: snapshot)
		}
	}

	nonisolated func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard let snapshot = DownloadSnapshot(to: action, download), snapshot.adamID == adamID else {
			return
		}

		Task {
			await removed(snapshot)
		}
	}

	func resumeOnce(performing action: (CheckedContinuation<Void, any Error>) -> Void) {
		resumeOnce(
			alreadyResumed: alreadyResumed,
			pkgHardLinkURL: pkgHardLinkURL,
			receiptHardLinkURL: receiptHardLinkURL,
			performing: action,
		)
		alreadyResumed = true
	}

	private nonisolated func resumeOnce(
		alreadyResumed: Bool,
		pkgHardLinkURL: URL?,
		receiptHardLinkURL: URL?,
		performing action: (CheckedContinuation<Void, any Error>) -> Void,
	) {
		guard !alreadyResumed else {
			return
		}
		guard let continuation = unsafe continuation else {
			MAS.printer.error("Failed to obtain download continuation for ADAM ID \(adamID)")
			return
		}

		action(continuation)
		deleteTempFolder(containing: pkgHardLinkURL, fileType: "pkg")
		deleteTempFolder(containing: receiptHardLinkURL, fileType: "receipt")
	}

	private func statusChanged(for snapshot: DownloadSnapshot) {
		// Refresh hard links to latest artifacts in the download directory
		do {
			let downloadFolderChildURLs = try FileManager.default.contentsOfDirectory(
				at: downloadFolderURL,
				includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
			)
			do {
				pkgHardLinkURL = try hardLinkURL(
					to: try downloadFolderChildURLs.compactMap { url -> (url: URL, date: Date)? in
						guard url.pathExtension == "pkg" else {
							return nil
						}

						let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
						return resourceValues.isRegularFile == true ? resourceValues.contentModificationDate.map { (url, $0) } : nil
					}
					.max { $0.date < $1.date }?
					.url,
					existing: pkgHardLinkURL,
				)
			} catch {
				MAS.printer.warning("Failed to link pkg for", snapshot.appNameAndVersion, error: error)
			}

			do {
				receiptHardLinkURL = try hardLinkURL(
					to: downloadFolderChildURLs.first { $0.lastPathComponent == "receipt" },
					existing: receiptHardLinkURL,
				)
			} catch {
				MAS.printer.warning("Failed to link receipt for", snapshot.appNameAndVersion, error: error)
			}
		} catch {
			MAS.printer.warning(
				"Failed to read contents of download folder",
				downloadFolderURL.path(percentEncoded: false).quoted,
				"for",
				snapshot.appNameAndVersion,
				error: error,
			)
		}

		switch snapshot.activePhaseType {
		case prevPhaseType:
			break
		case
			.downloading where prevPhaseType == .processing,
			.downloaded where prevPhaseType == .downloading,
			.performing:
			MAS.printer.clearCurrentLine(of: .standardOutput)
			MAS.printer.notice(snapshot.activePhaseType, snapshot.appNameAndVersion)
		default:
			break
		}

		if
			FileHandle.standardOutput.isTerminal,
			snapshot.phasePercentComplete != 0 || snapshot.activePhaseType != .processing
		{
			// Output the progress bar iff connected to a terminal
			let totalLength = 60
			let completedLength = Int(snapshot.phasePercentComplete * Float(totalLength))
			MAS.printer.clearCurrentLine(of: .standardOutput)
			MAS.printer.info(
				String(repeating: "#", count: completedLength),
				String(repeating: "-", count: totalLength - completedLength),
				" ",
				UInt64((snapshot.phasePercentComplete * 100).rounded()),
				"% ",
				snapshot.activePhaseType.performed,
				separator: "",
				terminator: "",
			)
		}

		prevPhaseType = snapshot.activePhaseType
	}

	private func removed(_ snapshot: DownloadSnapshot) async {
		MAS.printer.clearCurrentLine(of: .standardOutput)

		do {
			if let error = snapshot.error {
				guard error is Ignorable else {
					throw error
				}

				MAS.printer.notice(PhaseType.downloaded, snapshot.appNameAndVersion)
				MAS.printer.notice(action.performing.capitalizingFirstCharacter, snapshot.appNameAndVersion)
				MAS.printer.info(
					String(describing: action).capitalizingFirstCharacter,
					"progress cannot be displayed",
					terminator: "",
				)
				try await install(appNameAndVersion: snapshot.appNameAndVersion)
				MAS.printer.clearCurrentLine(of: .standardOutput)
			} else {
				guard !snapshot.isFailed else {
					throw MASError.error("Failed to download \(snapshot.appNameAndVersion)")
				}
				guard !shouldCancel(snapshot.version, false) else {
					resumeOnce { $0.resume() }
					return
				}
				guard !snapshot.isCancelled else {
					throw MASError.error("Download cancelled for \(snapshot.appNameAndVersion)")
				}
			}

			MAS.printer.notice(action.performed.capitalizingFirstCharacter, snapshot.appNameAndVersion)
			resumeOnce { $0.resume() }
		} catch {
			resumeOnce { $0.resume(throwing: error) }
		}
	}

	private func hardLinkURL(to url: URL?, existing existingHardLinkURL: URL?) throws -> URL? {
		guard let url, try !url.linksToSameInode(as: existingHardLinkURL) else {
			return existingHardLinkURL
		}

		let fileManager = FileManager.default
		let hardLinkURL = try fileManager.url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: URL.homeDirectory,
			create: true,
		)
		.appending(path: "\(adamID)-\(url.lastPathComponent)", directoryHint: .notDirectory)
		try fileManager.linkItem(at: url, to: hardLinkURL)
		return hardLinkURL
	}

	private func install(appNameAndVersion: String) async throws {
		guard let pkgHardLinkPath = pkgHardLinkURL?.path(percentEncoded: false) else {
			throw MASError.error("Failed to find pkg to \(action) \(appNameAndVersion)")
		}
		guard let receiptHardLinkURL else {
			throw MASError.error("Failed to find receipt to import for \(appNameAndVersion)")
		}

		let (_, standardErrorString) = try await run(
			"/usr/sbin/installer",
			"-dumplog",
			"-pkg",
			pkgHardLinkPath,
			"-target",
			"/",
			errorMessage: "Failed to \(action) \(appNameAndVersion) from \(pkgHardLinkPath)",
		) { process in try run(asEffectiveUID: 0, andEffectiveGID: 0) { try process.run() } }

		let appFolderURLMatches = standardErrorString.matches(of: unsafe appFolderURLRegex)
		// swiftlint:disable:next prefer_key_path
		guard let appFolderURLSubstring = appFolderURLMatches.compactMap({ $0.1 }).min(by: { $0.count < $1.count }) else {
			throw MASError.error( // swiftformat:disable:previous preferKeyPath
				"Failed to find app folder URL in installer output for \(appNameAndVersion)",
				error: standardErrorString,
			)
		}
		guard let appFolderURL = URL(string: String(appFolderURLSubstring)) else {
			throw MASError.error(
				"Failed to parse app folder URL for \(appNameAndVersion) from \(appFolderURLSubstring)",
				error: standardErrorString,
			)
		}

		let receiptURL = appFolderURL.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory)
		do {
			let fileManager = FileManager.default
			try run(asEffectiveUID: 0, andEffectiveGID: 0) {
				if fileManager.fileExists(atPath: receiptURL.path(percentEncoded: false)) {
					try fileManager.removeItem(at: receiptURL)
				} else {
					try fileManager.createDirectory(at: receiptURL.deletingLastPathComponent(), withIntermediateDirectories: true)
				}
				try fileManager.copyItem(at: receiptHardLinkURL, to: receiptURL)
				try fileManager.setAttributes(
					[.ownerAccountID: 0, .groupOwnerAccountID: 0],
					ofItemAtPath: receiptURL.path(percentEncoded: false),
				)
			}
		} catch {
			throw MASError.error(
				"""
				Failed to copy receipt for \(appNameAndVersion) from \(receiptHardLinkURL.path(percentEncoded: false).quoted)\
				 to \(receiptURL.path(percentEncoded: false).quoted)
				""",
				error: error,
			)
		}

		_ = try await run(
			"/usr/bin/mdimport",
			appFolderURL.path(percentEncoded: false),
			errorMessage: "Failed to \(action) \(appNameAndVersion) from \(pkgHardLinkPath)",
		)

		LSRegisterURL(appFolderURL as NSURL, true) // swiftlint:disable:this legacy_objc_type
	}
}

private struct DownloadSnapshot: Sendable { // swiftlint:disable:this one_declaration_per_file
	let adamID: ADAMID
	let version: String?
	let appNameAndVersion: String
	let activePhaseType: PhaseType
	let phasePercentComplete: Float
	let isCancelled: Bool
	let isFailed: Bool
	let error: (any Error)?

	init?(to action: AppStoreAction, _ download: SSDownload) {
		guard let metadata = download.metadata, let status = download.status else {
			return nil
		}

		adamID = metadata.itemIdentifier
		version = metadata.bundleVersion
		appNameAndVersion = "\(metadata.title ?? "unknown app") (\(version ?? "unknown version"))"
		activePhaseType = PhaseType(action, rawValue: status.activePhase?.phaseType)
		phasePercentComplete = status.phasePercentComplete
		isCancelled = status.isCancelled
		isFailed = status.isFailed
		error = status.error.map { $0 as NSError }.map { error in
			error.domain == "PKInstallErrorDomain" && error.code == 201 ? Ignorable.installerWorkaround : error as any Error
		}
	}
}

private enum Ignorable: Error { // swiftlint:disable:this one_declaration_per_file
	case installerWorkaround
}

private enum PhaseType: Equatable, Sendable { // swiftlint:disable:this one_declaration_per_file
	case processing // swiftlint:disable:this sorted_enum_cases
	case downloading
	case downloaded // swiftlint:disable:this sorted_enum_cases
	case performing(AppStoreAction) // swiftlint:disable:this sorted_enum_cases

	var performed: String {
		switch self {
		case .processing:
			"processed"
		case // swiftformat:disable:this sortSwitchCases
			.downloading,
			.downloaded:
			"downloaded"
		case let .performing(action):
			action.performed
		}
	}

	init(_ action: AppStoreAction, rawValue: Int64?) {
		self =
			switch rawValue {
			case 0:
				.downloading
			case 1:
				.performing(action)
			case 5:
				.downloaded
			default:
				.processing
			}
	}
}

extension PhaseType: CustomStringConvertible {
	var description: String {
		switch self {
		case .processing:
			"Processing"
		case .downloading:
			"Downloading"
		case .downloaded:
			"Downloaded"
		case let .performing(action):
			action.performing
		}
	}
}

private extension String {
	var capitalizingFirstCharacter: Self {
		prefix(1).capitalized + dropFirst()
	}
}

private extension URL {
	func linksToSameInode(as url: URL?) throws -> Bool {
		guard let url, url.isFileURL, isFileURL else {
			return false
		}
		guard let fileID1 = try resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(path(percentEncoded: false))")
		}
		guard let fileID2 = try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(url.path(percentEncoded: false))")
		}

		return fileID1.isEqual(fileID2)
	}
}

private func deleteTempFolder(containing url: URL?, fileType: String) {
	url.map { url in
		do {
			try FileManager.default.removeItem(at: url.deletingLastPathComponent())
		} catch {
			MAS.printer.warning(
				"Failed to delete temp folder containing",
				fileType,
				url.path(percentEncoded: false),
				error: error,
			)
		}
	}
}

private nonisolated(unsafe) let appFolderURLRegex = /PackageKit: Registered bundle (\S+) for uid 0/
