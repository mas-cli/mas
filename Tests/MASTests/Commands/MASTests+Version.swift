//
// MASTests+Version.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func outputsVersion() {
		let actual = consequencesOf(try MAS.Version.parse([]).run())
		let expected = Consequences(nil, "\(MAS.version)\n")
		#expect(actual == expected)
	}
}
