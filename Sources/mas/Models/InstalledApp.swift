//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct InstalledApp: Sendable {
	let adamID: ADAMID
	let bundleID: String
	let name: String
	// periphery:ignore
	let path: String
	let version: String

	func matches(_ appID: AppID) -> Bool {
		switch appID {
		case let .adamID(adamID):
			self.adamID == adamID
		case let .bundleID(bundleID):
			self.bundleID == bundleID
		}
	}
}
