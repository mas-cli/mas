//
// VerboseOptionGroup.swift
// mas
//
// Created by Ross Goldberg on 2025-05-08.
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct VerboseOptionGroup: ParsableArguments {
	@Flag(help: "Display warnings about app IDs unknown to the Mac App Store")
	var verbose = false
}
