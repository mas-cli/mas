//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct InstalledApp: AppIdentifying, Hashable, Sendable {
	let adamID: ADAMID
	let bundleID: String
	let name: String
	let path: String
	let version: String
}
