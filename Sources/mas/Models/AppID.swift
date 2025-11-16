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

	func adamID(searcher: some AppStoreSearcher) async throws -> ADAMID {
		switch self {
		case let .adamID(adamID):
			adamID
		case .bundleID:
			try await searcher.lookup(appID: self).adamID
		}
	}
}

typealias ADAMID = UInt64

extension [AppID] {
	func adamIDs(from searcher: some AppStoreSearcher) async -> [ADAMID] {
		await compactMap(attemptingTo: "get ADAM ID for") { try await $0.adamID(searcher: searcher) }
	}

	func lookupResults(from searcher: some AppStoreSearcher) async -> [SearchResult] {
		await compactMap(attemptingTo: "lookup app for") { try await searcher.lookup(appID: $0) }
	}
}
