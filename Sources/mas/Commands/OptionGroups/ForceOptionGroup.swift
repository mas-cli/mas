//
// ForceOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct ForceOptionGroup: ParsableArguments {
	@Flag(help: "Force reinstall")
	var force = false
}
