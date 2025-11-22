//
// VerboseOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct VerboseOptionGroup: ParsableArguments {
	@Flag(help: "Output warnings about app IDs unknown to the App Store")
	var verbose = false
}
