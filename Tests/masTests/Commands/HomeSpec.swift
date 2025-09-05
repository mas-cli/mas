//
// HomeSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

@Test
func cannotFindAppHomeForUnknownAppID() async {
	#expect( // swiftformat:disable:next indent
		await consequencesOf(try await MAS.Home.parse(["999"]).run(searcher: MockAppStoreSearcher()))
		== UnvaluedConsequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for app ID 999\n")
	) // swiftformat:disable:previous indent
}
