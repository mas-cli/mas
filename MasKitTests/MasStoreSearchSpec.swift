//
//  MasStoreSearchSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Quick
import Nimble

class MasStoreSearchSpec: QuickSpec {
    override func spec() {
        let appId = 803453959
        let urlSession = MockNetworkSessionFromFile(responseFile: "lookup/slack.json")
        let storeSearch = MasStoreSearch(networkManager: NetworkManager(session: urlSession))

        describe("store search") {
            it("can find slack") {
                let result = try! storeSearch.lookup(app: appId.description)
                expect(result).toNot(beNil())
                expect(result!.trackId) == appId

                expect(result!.bundleId) == "com.tinyspeck.slackmacgap"
                expect(result!.price) == 0
                expect(result!.sellerName) == "Slack Technologies, Inc."
                expect(result!.sellerUrl) == "https://slack.com"
                expect(result!.trackName) == "Slack"
                expect(result!.trackViewUrl) == "https://itunes.apple.com/us/app/slack/id803453959?mt=12&uo=4"
                expect(result!.version) == "3.3.3"
            }
        }
    }
}
