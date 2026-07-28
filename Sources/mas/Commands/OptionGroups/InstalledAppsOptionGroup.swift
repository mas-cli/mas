//
// InstalledAppsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct InstalledAppsOptionGroup: ParsableArguments {
	@OptionGroup
	private var forceBundleIDOptionGroup: ForceBundleIDOptionGroup // swiftformat:disable:this organizeDeclarations
	@Argument(help: .init("App ID", valueName: "app-id"))
	private(set) var appIDStrings = [String]()

	var appIDs: [AppID] {
		appIDStrings.map { .init(from: $0, forceBundleID: forceBundleIDOptionGroup.forceBundleID) }
	}

	func installedApps(withFullJSON: Bool) async -> [InstalledApp] {
		await mas::installedApps(withAppIDs: appIDs, withFullJSON: withFullJSON) { appID in
			MAS.printer.error("Failed to find installed app with \(appID)")
		}
	}
}
