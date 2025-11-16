//
// MASTests+SignOut.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test(.disabled())
	func signsOut() {
		let actual = consequencesOf(try MAS.main(try MAS.SignOut.parse([])))
		let expected = Consequences()
		#expect(actual == expected)
	}
}
