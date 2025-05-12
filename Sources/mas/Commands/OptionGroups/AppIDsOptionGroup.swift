//
// AppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct AppIDsOptionGroup: ParsableArguments {
	@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
	var appIDs: [AppID]
}
