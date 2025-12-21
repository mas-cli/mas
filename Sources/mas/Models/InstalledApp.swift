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

	var isTestFlight: Bool {
		adamID == 0
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
