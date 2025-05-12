//
// SearchTermOptionGroup.swift
// mas
//
// Created by Ross Goldberg on 2025-05-08.
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct SearchTermOptionGroup: ParsableArguments {
	@Argument(help: ArgumentHelp("Search terms are concatenated into a single search", valueName: "search-term"))
	var searchTermElements: [String]

	var searchTerm: String {
		searchTermElements.joined(separator: " ")
	}
}
