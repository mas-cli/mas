//
// IgnoreEntry.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

struct IgnoreEntry: Codable, Hashable, Sendable {
	let adamID: ADAMID
	let version: String?

	init(adamID: ADAMID, version: String? = nil) {
		self.adamID = adamID
		self.version = version
	}

	func matches(adamID: ADAMID, version: String) -> Bool {
		guard self.adamID == adamID else {
			return false
		}

		return self.version == nil || self.version == version
	}
}
