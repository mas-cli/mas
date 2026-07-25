//
// AppStoreAction.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

private import CommerceKit
private import CoreFoundation
private import CoreServices
private import Foundation
private import ObjectiveC
private import OrderedCollections
private import StoreFoundation
private import Subprocess
private import System // swiftlint:disable:this unused_import

enum AppStoreAction: String {
	case get
	case install
	case update

	var performed: String {
		switch self {
		case .get:
			"got"
		case .install:
			"installed"
		case .update:
			"updated"
		}
	}

	var performing: String {
		switch self {
		case .get:
			"getting"
		case .install:
			"installing"
		case .update:
			"updating"
		}
	}

	func apps(withAppIDs appIDs: [AppID], force: Bool) async {
		await apps(withADAMIDs: await appIDs.catalogApps.map(\.adamID), force: force)
	}

	func apps(withADAMIDs adamIDs: [ADAMID], force: Bool) async {
		let installedAppByADAMID = await installedApps(withAppIDs: adamIDs.map(AppID.adamID), withFullJSON: false) { _ in }
			.reduce(into: [ADAMID: InstalledApp]()) { $0[$1.adamID] = $1 }
		await apps(
			withADAMIDs: force
				? adamIDs
				: adamIDs.filter { adamID in
					guard let installedApp = installedAppByADAMID[adamID] else {
						return true
					}

					MAS.printer.warning("Already ", performed, " ", installedApp.name, " (", adamID, ")", separator: "")
					return false
				},
		)
	}

	func apps(withADAMIDs adamIDs: [ADAMID]) async {
		guard !adamIDs.isEmpty else {
			return
		}

		await OrderedSet(adamIDs).forEach(attemptTo: "\(self) app for ADAM ID") { adamID in
			try await app(withADAMID: adamID) { _, _ in false }
		}
	}

	func app(withADAMID adamID: ADAMID, shouldCancel: @escaping @Sendable (String?, Bool) -> Bool) async throws {
		let (eventStream, eventContinuation) = AsyncStream.makeStream(of: QueueEvent.self)
		let observerUUID = await DownloadQueueObserver(
			action: self,
			adamID: adamID,
			shouldCancel: shouldCancel,
			continuation: eventContinuation,
		)
		.start()
		eventContinuation.onTermination = { _ in
			Task { @MainActor in CKDownloadQueue.shared().removeObserver(observerUUID) }
		}
		defer { eventContinuation.finish() }
		try await withCheckedThrowingContinuation { continuation in
			let purchase = SSPurchase(
				buyParameters: """
					productType=C&price=0&pg=default&appExtVrsId=0&pricingParameters=\
					\(self == .get ? "STDQ&macappinstalledconfirmed=1" : "STDRDL")&salableAdamId=\(adamID)
					""",
			)
			purchase.isRedownload = self != .get // Possibly unnecessary
			purchase.isUpdate = self == .update // Possibly unnecessary
			purchase.itemIdentifier = adamID
			let downloadMetadata = SSDownloadMetadata(kind: "software")
			downloadMetadata.itemIdentifier = adamID
			purchase.downloadMetadata = downloadMetadata
			CKPurchaseController.shared().perform(purchase, withOptions: 0) { _, _, error, response in
				if let error {
					continuation.resume(throwing: error)
				} else if response?.downloads?.isEmpty != false {
					continuation.resume(throwing: MASError.error("Failed to initiate download for ADAM ID \(adamID)"))
				} else {
					continuation.resume()
				}
			}
		} as Void
		let downloadFolderURL = URL(folderPath: "\(CKDownloadDirectory(nil))/\(adamID)")
		var pkgHardLinkURL = URL?.none
		defer { deleteTempFolder(containing: pkgHardLinkURL, fileType: "pkg") }
		var receiptHardLinkURL = URL?.none
		defer { deleteTempFolder(containing: receiptHardLinkURL, fileType: "receipt") }
		var prevPhaseType = PhaseType.processing
		for await event in eventStream {
			try Task.checkCancellation()
			switch event {
			case let .statusChanged(snapshot):
				// Refresh hard links to latest artifacts in the download folder
				do {
					let downloadFolderChildURLs = try FileManager.default.contentsOfDirectory(
						at: downloadFolderURL,
						includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
					)
					do {
						pkgHardLinkURL = try hardLinkURL(
							to: try downloadFolderChildURLs.compactMap { url in
								guard url.pathExtension == "pkg" else {
									return (url: URL, date: Date)?.none
								}

								let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
								return
									resourceValues.isRegularFile == true ? resourceValues.contentModificationDate.map { (url, $0) } : nil
							}
								.max { $0.date < $1.date }? // swiftformat:disable:this indent
								.url, // swiftformat:disable:this indent
							existing: pkgHardLinkURL,
							adamID: adamID,
						)
					} catch {
						MAS.printer.warning("Failed to link pkg for", snapshot.appNameAndVersion, error: error)
					}
					do {
						receiptHardLinkURL = try hardLinkURL(
							to: downloadFolderChildURLs.first { $0.lastPathComponent == "receipt" },
							existing: receiptHardLinkURL,
							adamID: adamID,
						)
					} catch {
						MAS.printer.warning("Failed to link receipt for", snapshot.appNameAndVersion, error: error)
					}
				} catch {
					MAS.printer.warning(
						"Failed to read contents of download folder",
						downloadFolderURL.filePath.quoted,
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
					.performing
				: // swiftformat:disable:this indent
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
					let completedLength = Int(snapshot.phasePercentComplete * .init(totalLength))
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
			case let .removed(snapshot):
				MAS.printer.clearCurrentLine(of: .standardOutput)
				let appFolderURL: URL?
				if let error = snapshot.error {
					guard error is Ignorable else {
						throw error
					}

					MAS.printer.notice(PhaseType.downloaded, snapshot.appNameAndVersion)
					MAS.printer.notice(performing.uppercasingFirst, snapshot.appNameAndVersion)
					MAS.printer.info(rawValue.uppercasingFirst, "progress cannot be displayed", terminator: "")
					appFolderURL = try await install(
						appNameAndVersion: snapshot.appNameAndVersion,
						pkgHardLinkURL: pkgHardLinkURL,
						receiptHardLinkURL: receiptHardLinkURL,
					)
					MAS.printer.clearCurrentLine(of: .standardOutput)
				} else {
					guard !snapshot.isFailed else {
						throw MASError.error("Failed to download \(snapshot.appNameAndVersion)")
					}
					guard !shouldCancel(snapshot.version, false) else {
						return
					}
					guard !snapshot.isCancelled else {
						throw MASError.error("Download cancelled for \(snapshot.appNameAndVersion)")
					}

					appFolderURL = snapshot.appFolderPath.map { .init(folderPath: $0) }
				}

				MAS.printer.notice(
					[performed.uppercasingFirst, snapshot.appNameAndVersion]
						+ (appFolderURL.map { ["in", $0.filePath] } ?? .init()),
				)

				if let appFolderURL {
					let fileManager = FileManager.default
					if
						try applicationsFolderURLs.contains(
							where: { applicationsFolderURL in
								var relationship = FileManager.URLRelationship.other
								try unsafe fileManager.getRelationship(
									&relationship,
									ofDirectoryAt: applicationsFolderURL,
									toItemAt: appFolderURL,
								)
								return relationship == .contains
							},
						)
					{
						let appFolderPath = appFolderURL.filePath
						let installedApps = await installedApps(matching: [.adamID(snapshot.adamID)], withFullJSON: false)
							.filter { $0.path != appFolderPath }
						if !installedApps.isEmpty {
							MAS.printer.warning(
								"Multiple installations of ",
								snapshot.name ?? "unknown app",
								" exist in the applications folders\n\n",
								performed.uppercasingFirst,
								":\n",
								appFolderPath,
								"\n\nOthers:\n",
								installedApps.map(\.path).sorted(using: .localizedStandard).joined(separator: "\n"),
								separator: "",
							)
						}
					} else {
						MAS.printer.warning(
							performed.uppercasingFirst,
							snapshot.appNameAndVersion,
							"outside of the applications folders, in",
							appFolderURL.filePath,
						)
					}
				}
				return
			}
		}
	}

	private func install(
		appNameAndVersion: String,
		pkgHardLinkURL: URL?,
		receiptHardLinkURL: URL?,
	) async throws -> URL {
		guard let pkgHardLinkPath = pkgHardLinkURL?.filePath else {
			throw MASError.error("Failed to find pkg to \(self) \(appNameAndVersion)")
		}
		guard let receiptHardLinkURL else {
			throw MASError.error("Failed to find receipt to import for \(appNameAndVersion)")
		}

		if
			(try? await run(.path("/usr/bin/sudo"), arguments: ["-n", "true"], output: .discarded))?
				.terminationStatus
				.isSuccess != true
		{
			MAS.printer.info()
		}
		let (_, standardErrorString) = try await run(
			.path("/usr/bin/sudo"),
			"/usr/sbin/installer",
			"-dumplog",
			"-pkg",
			pkgHardLinkPath,
			"-target",
			"/",
			errorMessage: "Failed to \(self) \(appNameAndVersion) from \(pkgHardLinkPath)",
		)

		guard
			let appFolderURLSubstring = standardErrorString
				.matches(of: appFolderURLRegex)
				.compactMap(\.1)
				.min(by: { $0.count < $1.count })
		else {
			throw MASError.error(
				"Failed to find app folder URL in installer output for \(appNameAndVersion)",
				cause: standardErrorString,
			)
		}
		guard let appFolderURL = URL(string: .init(appFolderURLSubstring)), appFolderURL.isFileURL else {
			throw MASError.error(
				"Failed to parse app folder URL for \(appNameAndVersion) from \(appFolderURLSubstring)",
				cause: standardErrorString,
			)
		}

		let receiptURL = appFolderURL.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory)
		let receiptPath = receiptURL.filePath
		let receiptHardLinkPath = receiptHardLinkURL.filePath
		_ = try await run(
			.path("/usr/bin/sudo"),
			"/bin/sh",
			"-c",
			#"/bin/mkdir -pm 755 "$1" && /bin/cp -cf "$2" "$3" && /usr/sbin/chown 0:0 "$3" && /bin/chmod 644 "$3""#,
			"--",
			receiptURL.deletingLastPathComponent().filePath,
			receiptHardLinkPath,
			receiptPath,
			errorMessage: // swiftformat:disable:next indent
				"Failed to copy receipt for \(appNameAndVersion) from \(receiptHardLinkPath.quoted) to \(receiptPath.quoted)",
		)

		_ = try await run(
			.path("/usr/bin/mdimport"),
			appFolderURL.filePath,
			errorMessage: "Failed to \(self) \(appNameAndVersion) from \(pkgHardLinkPath)",
		)

		LSRegisterURL(appFolderURL as CFURL, true)

		return appFolderURL
	}
}

typealias AppStore = AppStoreAction

private enum QueueEvent { // swiftlint:disable:this one_declaration_per_file
	case statusChanged(DownloadSnapshot) // swiftlint:disable:this sorted_enum_cases
	case removed(DownloadSnapshot) // swiftlint:disable:this sorted_enum_cases
}

private final class DownloadQueueObserver: NSObject, CKDownloadQueueObserver {
	private let action: AppStoreAction // swiftlint:disable:previous one_declaration_per_file
	private let adamID: ADAMID
	private let shouldCancel: (String?, Bool) -> Bool
	private let continuation: AsyncStream<QueueEvent>.Continuation

	init(
		action: AppStoreAction,
		adamID: ADAMID,
		shouldCancel: @escaping (String?, Bool) -> Bool,
		continuation: AsyncStream<QueueEvent>.Continuation,
	) {
		self.action = action
		self.adamID = adamID
		self.shouldCancel = shouldCancel
		self.continuation = continuation
	}

	deinit {}

	@MainActor
	func start() -> String {
		CKDownloadQueue.shared().add(self)
	}

	func downloadQueue(_: CKDownloadQueue, changedWithAddition _: SSDownload) {}

	func downloadQueue(_ queue: CKDownloadQueue, statusChangedFor download: SSDownload) {
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

		continuation.yield(.statusChanged(snapshot))
	}

	func downloadQueue(_: CKDownloadQueue, changedWithRemoval download: SSDownload) {
		guard let snapshot = DownloadSnapshot(to: action, download), snapshot.adamID == adamID else {
			return
		}

		continuation.yield(.removed(snapshot))
	}
}

private struct DownloadSnapshot { // swiftlint:disable:this one_declaration_per_file
	let adamID: ADAMID
	let version: String?
	let name: String?
	let appNameAndVersion: String
	let activePhaseType: PhaseType
	let phasePercentComplete: Float
	let appFolderPath: String?
	let isCancelled: Bool
	let isFailed: Bool
	let error: (any Error)?

	init?(to action: AppStoreAction, _ download: SSDownload) {
		guard let metadata = download.metadata, let status = download.status else {
			return nil
		}

		adamID = metadata.itemIdentifier
		name = metadata.title
		version = metadata.bundleVersion
		appNameAndVersion = "\(metadata.title ?? "unknown app") (\(version ?? "unknown version"))"
		activePhaseType = .init(action, rawValue: status.activePhase?.phaseType)
		phasePercentComplete = status.phasePercentComplete
		appFolderPath = download.installPath
		isCancelled = status.isCancelled
		isFailed = status.isFailed
		error = status.error.map { error in
			if case let error as NSError = error, error.domain == "PKInstallErrorDomain", error.code == 201 {
				Ignorable.installerWorkaround
			} else {
				error
			}
		}
	}
}

private enum Ignorable: Error { // swiftlint:disable:this one_declaration_per_file
	case installerWorkaround
}

private enum PhaseType: Equatable { // swiftlint:disable:this one_declaration_per_file
	case processing // swiftlint:disable:this sorted_enum_cases
	case downloading
	case downloaded // swiftlint:disable:this sorted_enum_cases
	case performing(AppStoreAction) // swiftlint:disable:this sorted_enum_cases

	var performed: String {
		switch self {
		case .processing:
			"processed"
		case .downloading, .downloaded: // swiftformat:disable:this sortSwitchCases
			"downloaded"
		case let .performing(action):
			action.performed
		}
	}

	init(_ action: AppStoreAction, rawValue: Int64?) {
		self = switch rawValue {
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
			action.performing.uppercasingFirst
		}
	}
}

private extension URL {
	func linksToSameInode(as url: URL?) throws -> Bool {
		guard let url, url.isFileURL, isFileURL else {
			return false
		}
		guard let fileID1 = try resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(filePath)")
		}
		guard let fileID2 = try url.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier else {
			throw MASError.error("Failed to get file resource identifier for \(url.filePath)")
		}

		return fileID1.isEqual(fileID2)
	}
}

private func hardLinkURL(to url: URL?, existing existingHardLinkURL: URL?, adamID: ADAMID) throws -> URL? {
	guard let url, try !url.linksToSameInode(as: existingHardLinkURL) else {
		return existingHardLinkURL
	}

	let fileManager = FileManager.default
	let hardLinkURL = try fileManager.url(
		for: .itemReplacementDirectory,
		in: .userDomainMask,
		appropriateFor: url,
		create: true,
	)
	.appending(path: "\(adamID)-\(url.lastPathComponent)", directoryHint: .notDirectory)
	try fileManager.linkItem(at: url, to: hardLinkURL)
	return hardLinkURL
}

private func deleteTempFolder(containing url: URL?, fileType: String) {
	if let url {
		do {
			try FileManager.default.removeItem(at: url.deletingLastPathComponent())
		} catch {
			MAS.printer.warning("Failed to delete temp folder containing", fileType, url.filePath, error: error)
		}
	}
}

private let appFolderURLRegex = /PackageKit: Registered bundle (\S+) for uid 0/
