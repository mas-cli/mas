//
// ForceOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct ForceOptionGroup: ParsableArguments {
	@Flag(help: "Force reinstall")
	var force = false
}
