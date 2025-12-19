//
// OptionalAppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct OptionalAppIDsOptionGroup: ParsableArguments {
	@OptionGroup
	private var forceBundleIDOptionGroup: ForceBundleIDOptionGroup
	@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
	private var appIDStrings = [String]()

	var appIDs: [AppID] {
		appIDStrings.map { AppID(from: $0, forceBundleID: forceBundleIDOptionGroup.forceBundleID) }
	}
}
