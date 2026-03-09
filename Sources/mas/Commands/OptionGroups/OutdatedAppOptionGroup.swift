//
// OutdatedAppOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct OutdatedAppOptionGroup: ParsableArguments {
	@Flag
	var accuracy = OutdatedAccuracy.inaccurate
	@Flag(
		name: .customLong("check-min-os"),
		inversion: .prefixedNo,
		help: "Check that macOS is new enough to install the latest app version",
	)
	var shouldCheckMinimumOSVersion = true
}
