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

extension Array where Element: AppIdentifying {
	func filter(by appIDsOptionGroup: any AppIDsOptionGroup, printer: Printer) -> [Element] {
		appIDsOptionGroup.appIDStrings.isEmpty
		? self // swiftformat:disable:this indent
		: appIDsOptionGroup.appIDs.flatMap { appID in
			let appIdentifyings = filter { appID.matches($0) }
			if appIdentifyings.isEmpty {
				printer.error(appID.notInstalledMessage)
			}
			return appIdentifyings
		}
	}
}
