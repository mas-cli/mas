//
// LuckySpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
internal import Quick

final class LuckySpec: AsyncSpec {
	override static func spec() {
		let searcher =
			ITunesSearchAppStoreSearcher(networkSession: MockNetworkSession(responseResource: "search/slack.json"))

		xdescribe("lucky command") {
			it("installs the first app matching a search") {
				await expecta(
					await consequencesOf(
						try await MAS.Lucky.parse(["Slack"]).run(installedApps: [], searcher: searcher)
					)
				)
					== UnvaluedConsequences()
			}
		}
	}
}
