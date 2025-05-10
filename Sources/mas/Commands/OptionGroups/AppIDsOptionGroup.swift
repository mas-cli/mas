//
// AppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct AppIDsOptionGroup: ParsableArguments {
	@Flag(name: .customLong("bundle"), help: ArgumentHelp("Process all app IDs as bundle IDs"))
	var forceBundleID = false
	@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
	var appIDStrings: [String]

	var appIDs: [AppID] {
		appIDStrings.compactMap { AppID(from: $0, forceBundleID: forceBundleID) }
	}
}
