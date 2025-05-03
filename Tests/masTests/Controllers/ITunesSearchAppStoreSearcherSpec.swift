//
// ITunesSearchAppStoreSearcherSpec.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-04.
// Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class ITunesSearchAppStoreSearcherSpec: AsyncSpec {
	override public static func spec() {
		describe("store") {
			it("can search for slack") {
				let searcher =
					ITunesSearchAppStoreSearcher(networkSession: MockNetworkSession(responseResource: "search/slack.json"))

				let consequences = await consequencesOf(try await searcher.search(for: "slack"))
				expect(consequences.value).to(haveCount(39))
				expect(consequences.error) == nil
				expect(consequences.stdout).to(beEmpty())
				expect(consequences.stderr).to(beEmpty())
			}
			it("can lookup slack") {
				let appID = 803_453_959 as AppID
				let searcher =
					ITunesSearchAppStoreSearcher(networkSession: MockNetworkSession(responseResource: "lookup/slack.json"))

				let consequences = await consequencesOf(try await searcher.lookup(appID: appID))
				expect(consequences.error) == nil
				expect(consequences.stdout).to(beEmpty())
				expect(consequences.stderr).to(beEmpty())

				guard let result = consequences.value else {
					fatalError("lookup result was nil")
				}

				expect(result.trackId) == appID
				expect(result.sellerName) == "Slack Technologies, Inc."
				expect(result.sellerUrl) == "https://slack.com"
				expect(result.trackName) == "Slack"
				expect(result.trackViewUrl) == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
				expect(result.version) == "3.3.3"
			}
		}
	}
}
