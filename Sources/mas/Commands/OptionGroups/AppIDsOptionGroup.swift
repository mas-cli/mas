//
// AppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

protocol AppIDsOptionGroup: ParsableArguments {
	var forceBundleIDOptionGroup: ForceBundleIDOptionGroup { get }
	var forceBundleID: Bool { get }
	var appIDStrings: [String] { get }
	var appIDs: [AppID] { get }
}

extension AppIDsOptionGroup {
	var forceBundleID: Bool {
		forceBundleIDOptionGroup.forceBundleID
	}

	var appIDs: [AppID] {
		appIDStrings.map { AppID(from: $0, forceBundleID: forceBundleID) }
	}

	func forEachAppID(printer: Printer, _ body: (AppID) async throws -> Void) async {
		for appID in appIDs {
			do {
				try await body(appID)
			} catch {
				printer.error(error: error)
			}
		}
	}
}

extension [InstalledApp] {
	func filter(by appIDsOptionGroup: some AppIDsOptionGroup, printer: Printer) -> [Element] {
		appIDsOptionGroup.appIDStrings.isEmpty
		? self // swiftformat:disable:this indent
		: appIDsOptionGroup.appIDs.flatMap { appID in
			let installedApps = filter { $0.matches(appID) }
			if installedApps.isEmpty {
				printer.error(appID.notInstalledMessage)
			}
			return installedApps
		}
	}
}
