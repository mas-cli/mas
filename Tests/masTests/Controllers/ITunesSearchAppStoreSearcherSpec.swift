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

public final class ITunesSearchAppStoreSearcherSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            MAS.initialize()
        }
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

                    let consequences = consequencesOf(try searcher.search(for: "slack").wait())
                    expect(consequences.value).to(haveCount(39))
                    expect(consequences.error) == nil
                    expect(consequences.stdout).to(beEmpty())
                    expect(consequences.stderr).to(beEmpty())
                }
            }

            context("when lookup used") {
                it("can find slack") {
                    let appID = 803_453_959 as AppID
                    let networkSession = MockFromFileNetworkSession(responseFile: "lookup/slack.json")
                    let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

                    let consequences = consequencesOf(try searcher.lookup(appID: appID).wait())
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
