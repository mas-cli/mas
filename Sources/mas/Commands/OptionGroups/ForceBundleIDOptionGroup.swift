//
// ForceBundleIDOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct ForceBundleIDOptionGroup: ParsableArguments {
	@Flag(name: .customLong("bundle"), help: "Process all app IDs as bundle IDs")
	private(set) var forceBundleID = false
}
