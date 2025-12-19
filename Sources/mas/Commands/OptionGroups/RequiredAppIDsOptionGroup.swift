//
// RequiredAppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct RequiredAppIDsOptionGroup: ParsableArguments {
	@OptionGroup
	private var forceBundleIDOptionGroup: ForceBundleIDOptionGroup
	@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
	private var appIDStrings: [String]

	var appIDs: [AppID] {
		appIDStrings.map { AppID(from: $0, forceBundleID: forceBundleIDOptionGroup.forceBundleID) }
	}
}
