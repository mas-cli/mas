//
// ForceOptionGroup.swift
// mas
//
// Created by Ross Goldberg on 2025-05-08.
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct ForceOptionGroup: ParsableArguments {
	@Flag(help: "Force reinstall")
	var force = false
}
