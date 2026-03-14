//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Atomics
private import Foundation
private import JSON
private import JSONAST
private import ObjectiveC
private import OrderedCollections

struct InstalledApp {
	let adamID: ADAMID
	let bundleID: String
	let name: String
	let path: String
	let version: String

	private let json: String

	var isTestFlight: Bool {
		adamID == 0
	}

	fileprivate init(for item: NSMetadataItem) {
		let valueByAttribute = item.values(forAttributes: item.attributes + [NSMetadataItemPathKey]) ?? [:]
		adamID = valueByAttribute["kMDItemAppStoreAdamID"] as? ADAMID ?? 0
		bundleID = String(describing: valueByAttribute[NSMetadataItemCFBundleIdentifierKey] ?? "")
		name = String(describing: valueByAttribute["_kMDItemDisplayNameWithExtensions"] ?? "").removingSuffix(".app")
		path = valueByAttribute[NSMetadataItemPathKey].map { pathAny in
			let path = String(describing: pathAny)
			return (try? URL(filePath: path, directoryHint: .isDirectory).resourceValues(forKeys: [.canonicalPathKey]))?
			.canonicalPath // swiftformat:disable:this indent
			?? path // swiftformat:disable:this indent
		}
		?? "" // swiftformat:disable:this indent
		version = String(describing: valueByAttribute[NSMetadataItemVersionKey] ?? "")
		json = String(
			describing: JSON.encode(
				OrderedDictionary(
					uniqueKeysWithValues: (
						valueByAttribute.map { ($0.keyMapped, AnyJSONEncodable(from: $1)) }
						+ [("name", AnyJSONEncodable(from: name))], // swiftformat:disable:this indent
					)
					.sorted(using: KeyPathComparator(\.0, comparator: NumericStringComparator.forward)),
				), // swiftformat:disable:previous indent
			),
		)
	}

	func matches(_ appID: AppID) -> Bool {
		switch appID {
		case let .adamID(adamID):
			self.adamID == adamID
		case let .bundleID(bundleID):
			self.bundleID == bundleID
		}
	}
}

extension InstalledApp: CustomStringConvertible {
	var description: String {
		json
	}
}

extension [InstalledApp] {
	func filter(for appIDs: [AppID]) -> [Element] {
		appIDs.isEmpty
		? self // swiftformat:disable:this indent
		: appIDs.flatMap { appID in
			let installedApps = filter { $0.matches(appID) }
			if installedApps.isEmpty {
				MAS.printer.error(appID.notInstalledMessage)
			}
			return installedApps
		}
	}
}

private extension String {
	var keyMapped: Self {
		switch self {
		case NSMetadataItemCFBundleIdentifierKey:
			"bundleID"
		case "_kMDItemDisplayNameWithExtensions":
			"displayNameWithExtensions"
		case "_kMDItemEngagementData":
			"engagementData"
		case "_kMDItemRecentOutOfSpotlightEngagementDates":
			"recentOutOfSpotlightEngagementDates"
		case "kMDItemAlternateNames":
			"alternateNames"
		case "kMDItemAppStoreAdamID":
			"adamID"
		case "kMDItemAppStoreCategory":
			"category"
		case "kMDItemAppStoreCategoryType":
			"categoryType"
		case "kMDItemAppStoreHasMetadataPlist":
			"hasMetadataPlist"
		case "kMDItemAppStoreHasReceipt":
			"hasReceipt"
		case "kMDItemAppStoreInstallerVersionID":
			"installerVersionID"
		case "kMDItemAppStoreIsAppleSigned":
			"isAppleSigned"
		case "kMDItemAppStoreParentalControls":
			"parentalControls"
		case "kMDItemAppStorePurchaseDate":
			"purchaseDate"
		case "kMDItemAppStoreReceiptIsMachineLicensed":
			"receiptIsMachineLicensed"
		case "kMDItemAppStoreReceiptIsRevoked":
			"receiptIsRevoked"
		case "kMDItemAppStoreReceiptIsVPPLicensed":
			"receiptIsVPPLicensed"
		case "kMDItemAppStoreReceiptType":
			"receiptType"
		case NSMetadataItemContentCreationDateKey:
			"contentCreationDate"
		case "kMDItemContentCreationDate_Ranking":
			"contentCreationDate_Ranking"
		case NSMetadataItemContentModificationDateKey:
			"contentModificationDate"
		case NSMetadataItemContentTypeKey:
			"contentType"
		case NSMetadataItemContentTypeTreeKey:
			"contentTypeTree"
		case NSMetadataItemCopyrightKey:
			"copyright"
		case NSMetadataItemDateAddedKey:
			"dateAdded"
		case NSMetadataItemDescriptionKey:
			"description"
		case NSMetadataItemDisplayNameKey:
			"displayName"
		case "kMDItemDocumentIdentifier":
			"documentIdentifier"
		case NSMetadataItemExecutableArchitecturesKey:
			"executableArchitectures"
		case NSMetadataItemExecutablePlatformKey:
			"executablePlatform"
		case NSMetadataItemFSContentChangeDateKey:
			"fileSystemContentChangeDate"
		case NSMetadataItemFSCreationDateKey:
			"fileSystemCreationDate"
		case "kMDItemFSCreatorCode":
			"fileSystemCreatorCode"
		case "kMDItemFSFinderFlags":
			"fileSystemFinderFlags"
		case "kMDItemFSHasCustomIcon":
			"fileSystemHasCustomIcon"
		case "kMDItemFSInvisible":
			"fileSystemInvisible"
		case "kMDItemFSIsExtensionHidden":
			"fileSystemIsExtensionHidden"
		case "kMDItemFSIsStationery":
			"fileSystemIsStationery"
		case "kMDItemFSLabel":
			"fileSystemLabel"
		case NSMetadataItemFSNameKey:
			"fileSystemName"
		case "kMDItemFSNodeCount":
			"fileSystemNodeCount"
		case "kMDItemFSOwnerGroupID":
			"fileSystemOwnerGroupID"
		case "kMDItemFSOwnerUserID":
			"fileSystemOwnerUserID"
		case NSMetadataItemFSSizeKey:
			"fileSystemSize"
		case "kMDItemFSTypeCode":
			"fileSystemTypeCode"
		case "kMDItemInterestingDate_Ranking":
			"interestingDate_Ranking"
		case NSMetadataItemKeywordsKey:
			"keywords"
		case NSMetadataItemKindKey:
			"kind"
		case NSMetadataItemLastUsedDateKey:
			"lastUsedDate"
		case "kMDItemLastUsedDate_Ranking":
			"lastUsedDate_Ranking"
		case "kMDItemLogicalSize":
			"logicalSize"
		case "kMDItemPhysicalSize":
			"physicalSize"
		case "kMDItemUseCount":
			"useCount"
		case "kMDItemUsedDates":
			"usedDates"
		case NSMetadataItemVersionKey:
			"version"
		default:
			replacing(unsafe keyRegex) { match in
				let output = match.output
				return output.1?.isEmpty == false ? "fileSystem" : output.2?.lowercased() ?? ""
			}
		}
	}
}

private extension URL {
	var installedAppURLs: [URL] {
		FileManager.default // swiftformat:disable indent
		.enumerator(at: self, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
		.map { enumerator in
			enumerator.compactMap { item in
				guard
					let url = item as? URL,
					(try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true,
					url.pathExtension == "app"
				else {
					return nil as URL?
				}

				enumerator.skipDescendants()
				return try? url.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory)
				.resourceValues(forKeys: [.fileSizeKey])
				.fileSize
				.flatMap { $0 > 0 ? url : nil }
			}
		}
		?? []
	} // swiftformat:enable indent
}

var installedApps: [InstalledApp] {
	get async throws {
		try await mas.installedApps(matching: "kMDItemAppStoreAdamID LIKE '*'")
	}
}

func installedApps(withADAMID adamID: ADAMID) async throws -> [InstalledApp] {
	try await installedApps(matching: "kMDItemAppStoreAdamID = \(adamID)")
}

@MainActor
func installedApps(matching metadataQuery: String) async throws -> [InstalledApp] {
	var observer = (any NSObjectProtocol)?.none
	defer {
		if let observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	let query = NSMetadataQuery()
	query.predicate = NSPredicate(format: metadataQuery)
	query.searchScopes = applicationsFolderURLs

	return try await withCheckedThrowingContinuation { continuation in
		let alreadyResumed = ManagedAtomic(false)
		observer = NotificationCenter.default.addObserver(
			forName: .NSMetadataQueryDidFinishGathering,
			object: query,
			queue: nil,
		) { notification in
			guard !alreadyResumed.exchange(true, ordering: .acquiringAndReleasing) else {
				return
			}
			guard let query = notification.object as? NSMetadataQuery else {
				continuation.resume(
					throwing: MASError.error(
						"Notification Center returned a \(type(of: notification.object)) instead of a NSMetadataQuery",
					),
				)
				return
			}

			query.stop()

			let installedApps = query.results
			.compactMap { ($0 as? NSMetadataItem).map(InstalledApp.init(for:)) } // swiftformat:disable:this indent
			.sorted(using: KeyPathComparator(\.name, comparator: .localizedStandard)) // swiftformat:disable:this indent

			if !["1", "true", "yes"].contains(ProcessInfo.processInfo.environment["MAS_NO_AUTO_INDEX"]?.lowercased()) {
				let installedAppPathSet = Set(installedApps.map(\.path))
				for installedAppURL in applicationsFolderURLs.flatMap(\.installedAppURLs)
				where !installedAppPathSet.contains(installedAppURL.filePath) { // swiftformat:disable:this indent
					MAS.printer.warning(
						"Found a likely App Store app that is not indexed in Spotlight in ",
						installedAppURL.filePath,
						"""


						Indexing now, which will not complete until sometime after mas exits

						Disable auto-indexing via: export MAS_NO_AUTO_INDEX=1
						""",
						separator: "",
					)
					Task {
						do {
							_ = try await run(
								"/usr/bin/mdimport",
								installedAppURL.filePath,
								errorMessage: "Failed to index the Spotlight data for \(installedAppURL.filePath)",
							)
						} catch {
							MAS.printer.error(error: error)
						}
					}
				}
			}

			continuation.resume(returning: installedApps)
		}

		query.start()
	}
}

private nonisolated(unsafe) let keyRegex = /^_?kMDItem(?:(FS)|(?:AppStore)?(\p{Upper}(?=\p{Lower})|\p{Upper}+(?=$|\p{Upper}\p{Lower}))?)?/
