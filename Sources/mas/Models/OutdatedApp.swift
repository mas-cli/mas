//
// OutdatedApp.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import JSONAST

struct OutdatedApp {
	let installedApp: InstalledApp
	let newVersion: String // periphery:ignore

	private let json: Lazy<String>

	init(installedApp: InstalledApp, newVersion: String) {
		self.installedApp = installedApp
		self.newVersion = newVersion
		var jsonObjectInstalled = installedApp.jsonObject.value
		jsonObjectInstalled.fields.insert(
			(newVersionKey, .string(newVersion)),
			at: jsonObjectInstalled.fields
				.map(\.key.rawValue)
				.lowerBound(of: newVersionKey.rawValue, using: NumericStringComparator.forward),
		)
		let jsonObject = jsonObjectInstalled
		json = .init(.init(describing: jsonObject))
	}
}

extension OutdatedApp: CustomStringConvertible {
	var description: String {
		json.value
	}
}

private let newVersionKey = JSON.Key("newVersion")
