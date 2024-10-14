//
//  MasStoreSearchSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class MasStoreSearchSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("url string") {
            it("contains the app name") {
                expect {
                    MasStoreSearch().searchURL(for: "myapp", inCountry: "US")?.absoluteString
                }
                    == "https://itunes.apple.com/search?media=software&entity=desktopSoftware&term=myapp&country=US"
            }
            it("contains the encoded app name") {
                expect {
                    MasStoreSearch().searchURL(for: "My App", inCountry: "US")?.absoluteString
                }
                    == "https://itunes.apple.com/search?media=software&entity=desktopSoftware&term=My%20App&country=US"
            }
        }
        describe("store") {
            context("when searched") {
                it("can find slack") {
                    let networkSession = NetworkSessionMockFromFile(responseFile: "search/slack.json")
                    let storeSearch = MasStoreSearch(networkManager: NetworkManager(session: networkSession))

                    expect {
                        try storeSearch.search(for: "slack").wait()
                    }
                    .to(haveCount(39))
                }
            }

            context("when lookup used") {
                it("can find slack") {
                    let appID: AppID = 803_453_959
                    let networkSession = NetworkSessionMockFromFile(responseFile: "lookup/slack.json")
                    let storeSearch = MasStoreSearch(networkManager: NetworkManager(session: networkSession))

                    var result: SearchResult?
                    do {
                        result = try storeSearch.lookup(appID: appID).wait()
                    } catch {
                        let maserror = error as! MASError
                        if case .jsonParsing(let nserror) = maserror {
                            fail("\(maserror) \(nserror!)")
                        }
                    }

                    guard let result else {
                        fatalError("lookup result was nil")
                    }

                    expect(result.trackId) == appID
                    expect(result.bundleId) == "com.tinyspeck.slackmacgap"
                    expect(result.price) == 0
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
