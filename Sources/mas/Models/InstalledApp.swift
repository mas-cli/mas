//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Atomics
private import CoreFoundation
private import Foundation
internal import JSONAST
private import JSONParsing
private import ObjectiveC

struct InstalledApp {
	let adamID: ADAMID
	let bundleID: String
	let name: String
	let path: String
	let version: String

	let jsonObject: Lazy<JSON.Object>

	private let jsonObjectRaw: JSON.Object
	private let json: Lazy<String>

	var isTestFlight: Bool {
		adamID == 0
	}

	fileprivate init(for item: NSMetadataItem, withFullJSON: Bool) {
		let valueByAttribute = item.values(
			forAttributes: withFullJSON
			? item.attributes + [NSMetadataItemPathKey] // swiftformat:disable:this indent
			: [
				"kMDItemAppStoreAdamID",
				NSMetadataItemCFBundleIdentifierKey,
				"_kMDItemDisplayNameWithExtensions",
				NSMetadataItemPathKey,
				NSMetadataItemVersionKey,
			],
		)
		?? .init() // swiftformat:disable:this indent
		adamID = valueByAttribute["kMDItemAppStoreAdamID"] as? ADAMID ?? 0
		bundleID = .init(describing: valueByAttribute[NSMetadataItemCFBundleIdentifierKey] ?? "")
		name = .init(describing: valueByAttribute["_kMDItemDisplayNameWithExtensions"] ?? "").removingSuffix(".app")
		path = valueByAttribute[NSMetadataItemPathKey].map { pathAny in
			let path = String(describing: pathAny)
			return (try? URL(folderPath: path).resourceValues(forKeys: [.canonicalPathKey]))?.canonicalPath ?? path
		}
		?? "" // swiftformat:disable:this indent
		version = .init(describing: valueByAttribute[NSMetadataItemVersionKey] ?? "")

		jsonObjectRaw = .init(valueByAttribute.map { (.init(rawValue: $0.key), .init(for: $0.value)) })
		let jsonObjectRaw = jsonObjectRaw
		let name = name
		jsonObject = .init(
			.init(
				(jsonObjectRaw.fields.map { (.init(rawValue: $0.rawValue.mappingKey), $1) } + [("name", .string(name))])
					.sorted(using: KeyPathComparator(\.0.rawValue, comparator: NumericStringComparator.forward)),
			),
		)
		let jsonObject = jsonObject
		json = .init(.init(jsonObject.value))
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
		json.value
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

private extension JSON.Node {
	init(for value: Any?) {
		self = switch value {
		case let jsonNode as JSON.Node:
			jsonNode
		case let number as NSNumber: // swiftlint:disable:this legacy_objc_type
			number === kCFBooleanTrue || number === kCFBooleanFalse
			? .bool(number.boolValue) // swiftformat:disable:this indent
			: .init(.init(describing: number)) ?? .null
		case let date as Date:
			.string(date.formatted(.iso8601))
		case let data as Data:
			data.isEmpty // swiftlint:disable:next void_function_in_ternary
			? .string("") // swiftformat:disable:this indent
			: {
				var hex = "0x"
				hex.reserveCapacity(2 + data.count * 2)
				return .string(
					data.reduce(into: hex) { hex, byte in
						let byteHex = String(byte, radix: 16)
						if byteHex.count < 2 {
							hex += "0"
						}
						hex += byteHex
					},
				)
			}()
		case let array as [Any?]:
			.array(.init(array.map { .init(for: $0) }))
		default:
			value.map { .string(.init(describing: $0)) } ?? .null // swiftformat:disable:this indent
		}
	}
}

private extension String {
	var mappingKey: Self {
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
			replacing(keyRegex) { match in
				let output = match.output
				return output.1?.isEmpty == false ? "fileSystem" : output.2?.lowercased() ?? ""
			}
		}
	}
}

private extension URL {
	var installedAppURLs: [URL] {
		FileManager.default
			.enumerator(at: self, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
			.map { enumerator in
				enumerator.compactMap { item in
					guard
						let url = item as? URL,
						(try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true,
						url.pathExtension == "app"
					else {
						return URL?.none
					}

					enumerator.skipDescendants()
					return try? url.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory)
						.resourceValues(forKeys: [.fileSizeKey])
						.fileSize
						.flatMap { $0 > 0 ? url : nil }
				}
			}
			?? .init()
	}
}

func installedApps(withFullJSON: Bool = false) async throws -> [InstalledApp] {
	try await installedApps(matching: "kMDItemAppStoreAdamID LIKE '*'", withFullJSON: withFullJSON)
}

func installedApps(withADAMID adamID: ADAMID, withFullJSON: Bool = false) async throws -> [InstalledApp] {
	try await installedApps(matching: "kMDItemAppStoreAdamID = \(adamID)", withFullJSON: withFullJSON)
}

@MainActor
func installedApps(matching metadataQuery: String, withFullJSON: Bool = false) async throws -> [InstalledApp] {
	var observer = (any NSObjectProtocol)?.none
	defer {
		if let observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	let query = NSMetadataQuery()
	query.predicate = .init(format: metadataQuery)
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
				.compactMap { ($0 as? NSMetadataItem).map { InstalledApp(for: $0, withFullJSON: withFullJSON) } }
				.sorted(using: KeyPathComparator(\.name, comparator: .localizedStandard))

			if !["1", "true", "yes"].contains(ProcessInfo.processInfo.environment["MAS_NO_AUTO_INDEX"]?.lowercased()) {
				let installedAppPathSet = Set(installedApps.map(\.path))
				for installedAppURL in applicationsFolderURLs.flatMap(\.installedAppURLs)
				where !installedAppPathSet.contains(installedAppURL.filePath) { // swiftformat:disable:this indent
					MAS.printer.warning(
						"Found a likely App Store app that is not indexed in Spotlight in ",
						installedAppURL.filePath,
						"""


						Indexing now; will likely complete sometime after mas exits

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

// swiftformat:disable:next docComments
// editorconfig-checker-disable-next-line
private let keyRegex = /^_?kMDItem(?:(FS)|(?:AppStore)?(\p{Upper}(?=\p{Lower})|\p{Upper}+(?=$|\p{Upper}\p{Lower}))?)?/
