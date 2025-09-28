//
// OptionalAppIDsOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct OptionalAppIDsOptionGroup: AppIDsOptionGroup {
	@OptionGroup
	var forceBundleIDOptionGroup: ForceBundleIDOptionGroup
	@Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
	var appIDStrings = [String]()
}
