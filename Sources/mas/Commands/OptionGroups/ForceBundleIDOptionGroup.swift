//
// ForceBundleIDOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct ForceBundleIDOptionGroup: ParsableArguments {
	@Flag(name: .customLong("bundle"), help: ArgumentHelp("Process all app IDs as bundle IDs"))
	var forceBundleID = false
}
