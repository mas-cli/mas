//
// MASTests+Version.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `outputs version`() {
		let actual = consequencesOf(try MAS.main(try MAS.Version.parse(.init())))
		let expected = Consequences(nil, "\(MAS.version)\n")
		#expect(actual == expected)
	}
}
