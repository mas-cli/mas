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
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("url string") {
            it("contains the search term") {
                expect {
                    ITunesSearchAppStoreSearcher()
                        .searchURL(
                            for: "myapp",
                            inRegion: findISORegion(forAlpha2Code: "US")
                        )?
                        .absoluteString
                }
                    == "https://itunes.apple.com/search?media=software&entity=desktopSoftware&country=US&term=myapp"
            }
            it("contains the encoded search term") {
                expect {
                    ITunesSearchAppStoreSearcher()
                        .searchURL(
                            for: "My App",
                            inRegion: findISORegion(forAlpha2Code: "US")
                        )?
                        .absoluteString
                }
                    == "https://itunes.apple.com/search?media=software&entity=desktopSoftware&country=US&term=My%20App"
            }
        }
        describe("store") {
            context("when searched") {
                it("can find slack") {
                    let networkSession = MockFromFileNetworkSession(responseFile: "search/slack.json")
                    let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

                    expect {
                        try searcher.search(for: "slack").wait()
                    }
                    .to(haveCount(39))
                }
            }

            context("when lookup used") {
                it("can find slack") {
                    let appID: AppID = 803_453_959
                    let networkSession = MockFromFileNetworkSession(responseFile: "lookup/slack.json")
                    let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

                    var result: SearchResult?
                    expect {
                        result = try searcher.lookup(appID: appID).wait()
                    }
                    .toNot(throwError())

                    guard let result else {
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
