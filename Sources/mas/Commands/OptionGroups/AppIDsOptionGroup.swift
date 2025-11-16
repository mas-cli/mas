//
// AppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

protocol AppIDsOptionGroup: ParsableArguments {
	var forceBundleIDOptionGroup: ForceBundleIDOptionGroup { get }
	var appIDStrings: [String] { get }
}

extension AppIDsOptionGroup {
	var appIDs: [AppID] {
		appIDStrings.map { AppID(from: $0, forceBundleID: forceBundleIDOptionGroup.forceBundleID) }
	}

	func forEachAppID(_ body: (AppID) async throws -> Void) async {
		for appID in appIDs {
			do {
				try await body(appID)
			} catch {
				MAS.printer.error(error: error)
			}
		}
	}
}

extension [InstalledApp] {
	func filter(by appIDsOptionGroup: some AppIDsOptionGroup) -> [Element] {
		appIDsOptionGroup.appIDStrings.isEmpty
		? self // swiftformat:disable:this indent
		: appIDsOptionGroup.appIDs.flatMap { appID in
			let installedApps = filter { $0.matches(appID) }
			if installedApps.isEmpty {
				MAS.printer.error(appID.notInstalledMessage)
			}
			return installedApps
		}
	}
}
