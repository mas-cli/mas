//
// MASTests+SignOut.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func signsOut() {
	#expect(consequencesOf(try MAS.SignOut.parse([]).run()) == Consequences())
}
