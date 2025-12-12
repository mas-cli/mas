//
// SSPurchase.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit
private import Foundation
private import ObjectiveC
private import StoreFoundation

extension SSPurchase {
	convenience init(_ action: AppStoreAction, appWithADAMID adamID: ADAMID) async {
		self.init(
			buyParameters: """
				productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
				\(action == .get ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
				"""
		)

		// Possibly unnecessary…
		isRedownload = action != .get
		isUpdate = action == .update

		itemIdentifier = adamID

		let downloadMetadata = SSDownloadMetadata(kind: "software")
		downloadMetadata.itemIdentifier = adamID
		self.downloadMetadata = downloadMetadata

		do {
			let (emailAddress, dsID) = try await appleAccount
			accountIdentifier = dsID
			appleID = emailAddress
		} catch {
			// Do nothing
		}
	}

	func download(shouldCancel: @Sendable @escaping (String?, Bool) -> Bool) async throws {
		let adamID = itemIdentifier
		let queue = CKDownloadQueue.shared()
		let observer = DownloadQueueObserver(adamID: adamID, shouldCancel: shouldCancel)
		let observerUUID = queue.add(observer)
		defer {
			queue.removeObserver(observerUUID)
		}

		try await withCheckedThrowingContinuation { continuation in
			observer.set(continuation: continuation)

			CKPurchaseController.shared().perform(self, withOptions: 0) { _, _, error, response in
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
	private let adamID: ADAMID
	private let shouldCancel: @Sendable (String?, Bool) -> Bool
	private let downloadFolderURL: URL

	private var prevPhaseType: PhaseType?
	private var pkgHardLinkURL: URL?
	private var receiptHardLinkURL: URL?
	private var alreadyResumed = false

	private nonisolated(unsafe) var continuation: CheckedContinuation<Void, any Error>?

	init(adamID: ADAMID, shouldCancel: @Sendable @escaping (String?, Bool) -> Bool) {
		self.adamID = adamID
		self.shouldCancel = shouldCancel
		downloadFolderURL = URL(fileURLWithPath: "\(CKDownloadDirectory(nil))/\(adamID)", isDirectory: true)
	}

	deinit {
		if !alreadyResumed, let continuation {
			continuation.resume(
				throwing: MASError.error("Observer deallocated before download completed for ADAM ID \(adamID)")
			)
		}
	}

	nonisolated func set(continuation: CheckedContinuation<Void, any Error>) {
		self.continuation = continuation
	}

	nonisolated func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {
		// Do nothing
	}

	nonisolated func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
		guard let snapshot = DownloadSnapshot(of: download), snapshot.adamID == adamID else {
			return
		}
		guard !snapshot.isCancelled, !snapshot.isFailed else {
			queue.removeDownload(withItemIdentifier: adamID)
			return
		}
		guard !shouldCancel(snapshot.version, true) else {
			queue.cancelDownload(download, promptToConfirm: false, askToDelete: false)
			return
		}

		Task {
			await statusChanged(snapshot)
		}
	}

	nonisolated func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard let snapshot = DownloadSnapshot(of: download), snapshot.adamID == adamID else {
			return
		}

		Task {
			await removed(snapshot)
		}
	}

	func statusChanged(_ snapshot: DownloadSnapshot) {
		// Refresh hard links to latest artifacts in the download directory
		do {
			let downloadFolderChildURLs = try FileManager.default.contentsOfDirectory(
				at: downloadFolderURL,
				includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey]
			)

			do {
				pkgHardLinkURL = try hardLinkURL(
					to: try downloadFolderChildURLs
					.compactMap { url -> (URL, Date)? in // swiftformat:disable indent
						guard url.pathExtension == "pkg" else {
							return nil
						}

						let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
						return resourceValues.isRegularFile == true ? resourceValues.contentModificationDate.map { (url, $0) } : nil
					}
					.max { $0.1 > $1.1 }?
					.0,
					existing: pkgHardLinkURL // swiftformat:enable indent
				)
			} catch {
				MAS.printer.warning("Failed to link pkg for", snapshot.appNameAndVersion, error: error)
			}

			do {
				receiptHardLinkURL = try hardLinkURL(
					to: downloadFolderChildURLs.first { $0.lastPathComponent == "receipt" },
					existing: receiptHardLinkURL
				)
			} catch {
				MAS.printer.warning("Failed to link receipt for", snapshot.appNameAndVersion, error: error)
			}
		} catch {
			MAS.printer.warning(
				"Failed to read contents of download folder",
				downloadFolderURL.path.quoted,
				"for",
				snapshot.appNameAndVersion,
				error: error
			)
		}

		let currPhaseType = snapshot.activePhaseType
		if prevPhaseType != currPhaseType {
			switch currPhaseType {
			case
				.downloading where prevPhaseType == .initial,
				.downloaded where prevPhaseType == .downloading,
				.installing:
				MAS.printer.progress(phaseType: currPhaseType, for: snapshot.appNameAndVersion)
			default:
				break
			}
		}

		let percentComplete = snapshot.percentComplete
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
				currPhaseType.description,
				separator: "",
				terminator: ""
			)
		}

		prevPhaseType = currPhaseType
	}

	func removed(_ snapshot: DownloadSnapshot) {
		MAS.printer.clearCurrentLine(of: .standardOutput)

		do {
			if let error = snapshot.error {
				guard error is Ignorable else {
					throw error
				}

				try install(appNameAndVersion: snapshot.appNameAndVersion)
			} else {
				guard !snapshot.isFailed else {
					throw MASError.error("Failed to download \(snapshot.appNameAndVersion)")
				}
				guard !snapshot.isCancelled else {
					guard shouldCancel(snapshot.version, false) else {
						throw MASError.error("Download cancelled for \(snapshot.appNameAndVersion)")
					}

					resumeOnce { $0.resume() }
					return
				}
			}

			MAS.printer.notice("Installed", snapshot.appNameAndVersion)
			resumeOnce { $0.resume() }
		} catch {
			resumeOnce { $0.resume(throwing: error) }
		}
	}

	func resumeOnce(performing action: (CheckedContinuation<Void, any Error>) -> Void) {
		guard !alreadyResumed else {
			return
		}
		guard let continuation else {
			MAS.printer.error("Failed to obtain download continuation for ADAM ID \(adamID)")
			return
		}

		alreadyResumed = true
		action(continuation)
		deleteTempFolder(containing: pkgHardLinkURL, fileType: "pkg")
		deleteTempFolder(containing: receiptHardLinkURL, fileType: "receipt")
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
					.trimmingCharacters(in: .whitespacesAndNewlines) // swiftformat:disable:this indent
					.prependIfNotEmpty("\n\nStandard output:\n") ?? "" // swiftformat:disable:this indent
				)\(String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
					.trimmingCharacters(in: .whitespacesAndNewlines)
					.prependIfNotEmpty("\n\nStandard error:\n") ?? "" // swiftformat:disable:this indent
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
			let appFolderURLResult = appFolderURLRegex
			.firstMatch(in: standardErrorText, range: NSRange(location: 0, length: standardErrorText.count)),
			let appFolderURLNSRange = appFolderURLResult.range(at: 1) as NSRange?,
			appFolderURLNSRange.location != NSNotFound,
			let appFolderURLRange = Range(appFolderURLNSRange, in: standardErrorText)
		else {
			throw MASError.error(
				"Failed to find app folder URL in installer output for \(appNameAndVersion)",
				error: standardErrorText
			)
		}
		guard let appFolderURL = URL(string: String(standardErrorText[appFolderURLRange])) else {
			throw MASError.error(
				"Failed to parse app folder URL for \(appNameAndVersion) from \(standardErrorText[appFolderURLRange])",
				error: standardErrorText
			)
		}

		return appFolderURL
	}
}

private struct DownloadSnapshot: Sendable { // swiftlint:disable:this one_declaration_per_file
	let adamID: ADAMID
	let version: String?
	let appNameAndVersion: String
	let activePhaseType: PhaseType?
	let percentComplete: Float
	let isCancelled: Bool
	let isFailed: Bool
	let error: (any Error)?

	init?(of download: SSDownload) {
		guard let metadata = download.metadata, let status = download.status else {
			return nil
		}

		adamID = metadata.itemIdentifier
		version = metadata.bundleVersion
		appNameAndVersion = "\(metadata.title ?? "unknown app") (\(version ?? "unknown version"))"
		activePhaseType = status.activePhase.flatMap { PhaseType(rawValue: $0.phaseType) }
		percentComplete = status.phasePercentComplete
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

private enum PhaseType: Int64 { // swiftlint:disable:this one_declaration_per_file
	case initial = 4 // swiftlint:disable:this sorted_enum_cases
	case downloading = 0
	case downloaded = 5 // swiftlint:disable:this sorted_enum_cases
	case installing = 1
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
		guard let fileID1 = try resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(path)")
		}
		guard let fileID2 = try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(url.path)")
		}

		return fileID1.isEqual(fileID2)
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
