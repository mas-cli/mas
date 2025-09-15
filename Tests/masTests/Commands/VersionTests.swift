//
// VersionTests.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test
func outputsVersion() {
	#expect(consequencesOf(try MAS.Version.parse([]).run()) == UnvaluedConsequences(nil, "\(MAS.version)\n"))
}
