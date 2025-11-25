//
// InstalledApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Foundation

struct InstalledApp: Sendable {
	let adamID: ADAMID
	let bundleID: String
	let name: String
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

extension [InstalledApp] {
	func filter(if shouldFilter: Bool, appCatalog: some AppCatalog, shouldWarnIfAppUnknown: Bool) async -> Self {
		shouldFilter
		? await compactMap { installedApp in // swiftformat:disable indent
			do {
				_ = try await appCatalog.lookup(appID: .adamID(installedApp.adamID))
				return installedApp
			} catch {
				error.printProblem(shouldWarnIfAppUnknown: shouldWarnIfAppUnknown, expectedAppName: installedApp.name)
				return nil
			}
		}
		: self
	} // swiftformat:enable indent
}
