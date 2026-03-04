//
// AppID.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

enum AppID: CustomStringConvertible {
	case adamID(ADAMID)
	case bundleID(String)

	var description: String {
		switch self {
		case let .adamID(adamID):
			"ADAM ID \(adamID)"
		case let .bundleID(bundleID):
			"bundle ID \(bundleID)"
		}
	}

	var notInstalledMessage: String {
		"No installed apps with \(self)"
	}

	init(from string: String, forceBundleID: Bool = false) {
		guard !forceBundleID, let adamID = ADAMID(string) else {
			self = .bundleID(string)
			return
		}

		self = .adamID(adamID)
	}
}

extension [AppID] { // swiftlint:disable:this file_types_order
	func lookupCatalogApps(using lookupAppFromAppID: @escaping @Sendable (AppID) async throws -> CatalogApp)
	async -> [CatalogApp] { // swiftformat:disable:this indent
		await concurrentCompactMap(attemptingTo: "lookup app for", lookupAppFromAppID)
	}
}

typealias ADAMID = UInt64
