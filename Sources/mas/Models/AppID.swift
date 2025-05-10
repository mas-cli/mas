//
// AppID.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

private import Foundation

enum AppID: CustomStringConvertible, Equatable, Hashable {
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

// swiftlint:disable:next one_declaration_per_file
protocol AppIdentifying {
	var adamID: ADAMID { get }
	var bundleID: String { get }
}

extension AppIdentifying {
	var id: AppID {
		bundleID.isEmpty
		? .adamID(adamID) // swiftformat:disable:this indent
		: .bundleID(bundleID)
	}
}
