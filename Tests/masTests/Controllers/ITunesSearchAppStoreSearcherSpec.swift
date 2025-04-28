//
//  ITunesSearchAppStoreSearcherSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class ITunesSearchAppStoreSearcherSpec: AsyncSpec {
	override public static func spec() {
		describe("url string") {
			it("contains the search term") {
				expect(
					consequencesOf(
						ITunesSearchAppStoreSearcher()
							.searchURL(
								for: "myapp",
								inRegion: findISORegion(forAlpha2Code: "US")
							)?
							.absoluteString
					)
				)
					== (
						"https://itunes.apple.com/search?media=software&entity=desktopSoftware&country=US&term=myapp",
						nil,
						"",
						""
					)
			}
			it("contains the encoded search term") {
				expect(
					consequencesOf(
						ITunesSearchAppStoreSearcher()
							.searchURL(
								for: "My App",
								inRegion: findISORegion(forAlpha2Code: "US")
							)?
							.absoluteString
					)
				)
					== (
						"https://itunes.apple.com/search?media=software&entity=desktopSoftware&country=US&term=My%20App",
						nil,
						"",
						""
					)
			}
		}
		describe("store") {
			context("when searched") {
				it("can find slack") {
					let networkSession = MockNetworkSession(responseFile: "search/slack.json")
					let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

					let consequences = await consequencesOf(try await searcher.search(for: "slack"))
					expect(consequences.value).to(haveCount(39))
					expect(consequences.error) == nil
					expect(consequences.stdout).to(beEmpty())
					expect(consequences.stderr).to(beEmpty())
				}
			}

			context("when lookup used") {
				it("can find slack") {
					let appID = 803_453_959 as AppID
					let networkSession = MockNetworkSession(responseFile: "lookup/slack.json")
					let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

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
}
