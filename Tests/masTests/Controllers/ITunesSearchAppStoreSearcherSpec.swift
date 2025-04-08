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
                await expecta(
                    await consequencesOf(
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
                await expecta(
                    await consequencesOf(
                        ITunesSearchAppStoreSearcher()
                            .searchURL(
                                for: "My App",
                                inRegion: findISORegion(forAlpha2Code: "US")
                            )?
                            .absoluteString
                    )
                )
                    == (
                        // swiftlint:disable:next line_length
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
                    let networkSession = MockFromFileNetworkSession(responseFile: "search/slack.json")
                    let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

                    let consequences = await consequencesOf(try await searcher.search(for: "slack"))
                    await expecta(consequences.value).to(haveCount(39))
                    await expecta(consequences.error) == nil
                    await expecta(consequences.stdout).to(beEmpty())
                    await expecta(consequences.stderr).to(beEmpty())
                }
            }

            context("when lookup used") {
                it("can find slack") {
                    let appID = 803_453_959 as AppID
                    let networkSession = MockFromFileNetworkSession(responseFile: "lookup/slack.json")
                    let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

                    let consequences = await consequencesOf(try await searcher.lookup(appID: appID))
                    await expecta(consequences.error) == nil
                    await expecta(consequences.stdout).to(beEmpty())
                    await expecta(consequences.stderr).to(beEmpty())

                    guard let result = consequences.value else {
                        fatalError("lookup result was nil")
                    }

                    await expecta(result.trackId) == appID
                    await expecta(result.sellerName) == "Slack Technologies, Inc."
                    await expecta(result.sellerUrl) == "https://slack.com"
                    await expecta(result.trackName) == "Slack"
                    await expecta(result.trackViewUrl) == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
                    await expecta(result.version) == "3.3.3"
                }
            }
        }
    }
}
