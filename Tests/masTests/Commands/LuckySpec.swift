//
// LuckySpec.swift
// masTests
//
// Created by Ben Chatelain on 2018-12-28.
// Copyright © 2018 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

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
					== (nil, "", "")
			}
		}
	}
}
