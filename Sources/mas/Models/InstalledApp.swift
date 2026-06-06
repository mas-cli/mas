//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import CoreFoundation
private import Foundation
internal import JSONAST
private import JSONParsing

struct InstalledApp {
	let adamID: ADAMID
	let bundleID: String
	let name: String
	let path: String
	let version: String

	private let jsonObjectRaw: JSON.Object
	private let _jsonObject: Lazy<JSON.Object>
	private let json: Lazy<String>

	var jsonObject: JSON.Object {
		_jsonObject.value
	}

	var isTestFlight: Bool {
		adamID == 0
	}

	init(adamID: ADAMID, bundleID: String, name: String, path: String, version: String) {
		self.adamID = adamID
		self.bundleID = bundleID
		self.name = name
		self.path = path
		self.version = version

		// Build the same attribute map the Spotlight-backed init produced, using the kMDItem* keys
		// so `JSON.Key.normalized` maps them to adamID/bundleID/path/version; the tail (sort + inject
		// "name") is identical to the original so `--json` output stays well-formed.
		let valueByAttribute: [String: Any] = [
			"kMDItemAppStoreAdamID": adamID,
			NSMetadataItemCFBundleIdentifierKey: bundleID,
			NSMetadataItemPathKey: path,
			NSMetadataItemVersionKey: version,
		]
		jsonObjectRaw = .init(valueByAttribute.map { (.init(rawValue: $0.key), .init(for: $0.value)) })
		let jsonObjectRaw = jsonObjectRaw
		let name = name
		_jsonObject = .init(
			.init(
				(jsonObjectRaw.fields.map { ($0.normalized, $1) } + [("name", .string(name))])
					.sorted(using: KeyPathComparator(\.0.rawValue, comparator: NumericStringComparator.forward)),
			),
		)
		let jsonObject = _jsonObject
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
			value.map { .string(.init(describing: $0)) } ?? .null
		}
	}
}

private extension JSON.Key {
	var normalized: Self {
		switch rawValue {
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
			.init(
				rawValue: rawValue.replacing(keyRegex) { match in
					let output = match.output
					return output.1?.isEmpty == false ? "fileSystem" : output.2?.lowercased() ?? ""
				},
			)
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
	installedAppsFromReceipts()
}

func installedApps(withADAMID adamID: ADAMID, withFullJSON: Bool = false) async throws -> [InstalledApp] {
	installedAppsFromReceipts().filter { $0.adamID == adamID }
}

// macOS 26 (Tahoe) no longer indexes the kMDItemAppStore* Spotlight attributes (kMDItemAppStoreAdamID
// is null even for installed apps), so the previous NSMetadataQuery-based discovery returned nothing.
// Enumerate App Store apps from each app's Contents/_MASReceipt/receipt — written by the App Store at
// install time — which is authoritative and Spotlight-independent.
private func installedAppsFromReceipts() -> [InstalledApp] {
	applicationsFolderURLs
	.flatMap(\.installedAppURLs) // swiftformat:disable:this indent
	.compactMap { appURL in
		guard
			let receipt = try? Data(
				contentsOf: appURL.appending(path: "Contents/_MASReceipt/receipt", directoryHint: .notDirectory),
			)
		else {
			return InstalledApp?.none
		}

		let attributes = receiptAttributes([UInt8](receipt))
		return InstalledApp(
			adamID: attributes[masReceiptAdamIDType].flatMap(adamID(fromReceiptValue:)) ?? 0,
			bundleID: attributes[masReceiptBundleIDType].flatMap(string(fromReceiptValue:)) ?? "",
			name: appURL.deletingPathExtension().lastPathComponent,
			path: appURL.filePath,
			version: attributes[masReceiptVersionType].flatMap(string(fromReceiptValue:)) ?? "",
		)
	}
	.sorted(using: KeyPathComparator(\.name, comparator: .localizedStandard))
}

// ─── Mac App Store receipt (DER PKCS#7) attribute reader ───
//
// The receipt's eContent is a SET of attributes, each:
//   SEQUENCE { type INTEGER, version INTEGER, value OCTET STRING }
// where the value wraps a single DER element:
//   type 1 (adamID) → INTEGER, type 2 (bundleID) → UTF8String, type 3 (version) → UTF8String.
// See: https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt

private let masReceiptAdamIDType = 1
private let masReceiptBundleIDType = 2
private let masReceiptVersionType = 3

// Walk the DER tree collecting receipt attributes as `type -> raw OCTET STRING value bytes`.
private func receiptAttributes(_ bytes: [UInt8]) -> [Int: [UInt8]] {
	var attributes: [Int: [UInt8]] = [:]

	func attribute(_ sequence: [UInt8]) -> (type: Int, value: [UInt8])? {
		var index = 0
		guard let typeElement = DER.element(sequence, &index), typeElement.tag == DER.integer else {
			return nil
		}
		guard let versionElement = DER.element(sequence, &index), versionElement.tag == DER.integer else {
			return nil
		}
		guard let valueElement = DER.element(sequence, &index), valueElement.tag == DER.octetString else {
			return nil
		}
		guard index == sequence.count else {
			return nil // exactly three elements
		}
		_ = versionElement
		return (Int(DER.unsignedInteger(typeElement.content)), valueElement.content)
	}

	func walk(_ bytes: [UInt8]) {
		var index = 0
		while index < bytes.count {
			let start = index
			guard let node = DER.element(bytes, &index) else {
				break
			}
			if node.tag == DER.sequence, let attribute = attribute(node.content) {
				attributes[attribute.type] = attribute.value
			}
			if node.tag & DER.constructed != 0 {
				walk(node.content) // descend into SEQUENCE / SET / context-tagged nodes
			} else if node.tag == DER.octetString {
				walk(node.content) // the eContent payload is wrapped in an OCTET STRING
			}
			if index <= start {
				break
			}
		}
	}

	walk(bytes)
	return attributes
}

private func adamID(fromReceiptValue value: [UInt8]) -> ADAMID? {
	var index = 0
	guard let inner = DER.element(value, &index), inner.tag == DER.integer else {
		return nil
	}
	return DER.unsignedInteger(inner.content)
}

private func string(fromReceiptValue value: [UInt8]) -> String? {
	var index = 0
	guard
		let inner = DER.element(value, &index),
		inner.tag == DER.utf8String || inner.tag == DER.ia5String || inner.tag == DER.printableString
	else {
		return nil
	}
	return String(bytes: inner.content, encoding: .utf8)
}

// Minimal DER reader supporting definite-length encodings (which is all DER uses).
private enum DER {
	static let integer: UInt8 = 0x02
	static let octetString: UInt8 = 0x04
	static let utf8String: UInt8 = 0x0C
	static let printableString: UInt8 = 0x13
	static let ia5String: UInt8 = 0x16
	static let sequence: UInt8 = 0x30
	static let constructed: UInt8 = 0x20

	// Parse one tag-length-value element starting at `index`, advancing `index` past it.
	static func element(_ bytes: [UInt8], _ index: inout Int) -> (tag: UInt8, content: [UInt8])? {
		guard index < bytes.count else {
			return nil
		}
		let tag = bytes[index]
		index += 1
		guard index < bytes.count else {
			return nil
		}
		var length = Int(bytes[index])
		index += 1
		if length & 0x80 != 0 {
			let byteCount = length & 0x7F
			guard byteCount >= 1, byteCount <= 4, index + byteCount <= bytes.count else {
				return nil
			}
			length = 0
			for _ in 0 ..< byteCount {
				length = (length << 8) | Int(bytes[index])
				index += 1
			}
		}
		guard length >= 0, index + length <= bytes.count else {
			return nil
		}
		let content = Array(bytes[index ..< (index + length)])
		index += length
		return (tag, content)
	}

	static func unsignedInteger(_ bytes: [UInt8]) -> UInt64 {
		var value: UInt64 = 0
		for byte in bytes {
			value = (value << 8) | UInt64(byte)
		}
		return value
	}
}

// swiftformat:disable:next docComments
// editorconfig-checker-disable-next-line
private let keyRegex = /^_?kMDItem(?:(FS)|(?:AppStore)?(\p{Upper}(?=\p{Lower})|\p{Upper}+(?=$|\p{Upper}\p{Lower}))?)?/
