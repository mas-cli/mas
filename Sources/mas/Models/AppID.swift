//
// AppID.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

enum AppID: CustomStringConvertible, Hashable {
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
		if !forceBundleID, let adamID = ADAMID(string) {
			self = .adamID(adamID)
			return
		}

		self = .bundleID(string)
	}

	func matches(_ appIdentifying: any AppIdentifying) -> Bool {
		switch self {
		case let .adamID(adamID):
			adamID == appIdentifying.adamID
		case let .bundleID(bundleID):
			bundleID == appIdentifying.bundleID
		}
	}

	func adamID(searcher: AppStoreSearcher) async throws -> ADAMID {
		switch self {
		case let .adamID(adamID):
			adamID
		case .bundleID:
			try await searcher.lookup(appID: self).adamID
		}
	}
}

typealias ADAMID = UInt64
