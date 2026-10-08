//
// JobsOptionGroup.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import ArgumentParser

struct JobsOptionGroup: ParsableArguments {
	@Option(name: [.customShort("j"), .long], help: "Maximum number of apps to download & install concurrently")
	private(set) var jobs = 4

	func validate() throws(ValidationError) {
		if jobs < 1 {
			throw .init("--jobs must be at least 1")
		}
	}
}
