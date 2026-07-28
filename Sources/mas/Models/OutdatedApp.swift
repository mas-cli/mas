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

	private let lazyJSON: Lazy<String>

	init(installedApp: InstalledApp, newVersion: String) {
		self.installedApp = installedApp
		self.newVersion = newVersion
		lazyJSON = .init(
			.init(
				describing: {
					var jsonObject = installedApp.jsonObject
					jsonObject.fields.insert(
						(newVersionKey, .string(newVersion)),
						at: jsonObject.fields
							.map(\.key.rawValue)
							.lowerBound(of: newVersionKey.rawValue, using: NumericStringComparator.forward),
					)
					return jsonObject
				}(),
			),
		)
	}
}

extension OutdatedApp: CustomStringConvertible {
	var description: String {
		lazyJSON.value
	}
}

private let newVersionKey = JSON.Key("newVersion")
