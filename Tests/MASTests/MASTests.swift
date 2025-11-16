//
// MASTests.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

@Suite(.serialized)
struct MASTests {
	init() {
		MAS.printer.resetErrorCount()
	}
}
