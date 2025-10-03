//
// MASTests+Version.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

extension MASTests {
	@Test
	static func outputsVersion() {
		#expect(consequencesOf(try MAS.Version.parse([]).run()) == Consequences(nil, "\(MAS.version)\n"))
	}
}
