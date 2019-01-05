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
        let urlSession = MockURLSession(responseFile: "lookup/slack.json")
        let storeSearch = MasStoreSearch(urlSession: urlSession)
        describe("store search") {
            it("can find slack") {
                // FIXME: Doesn't work offline
//                2019-01-05 08:37:33.764724-0700 xctest[76864:1854467] TIC TCP Conn Failed [1:0x100c90f90]: 1:50 Err(50)
//                2019-01-05 08:37:33.774861-0700 xctest[76864:1854467] Task <8D1421BF-F9A3-4716-BCB0-803438C7E3E8>.<1> HTTP load failed (error code: -1009 [1:50])
//                2019-01-05 08:37:33.774983-0700 xctest[76864:1854467] Task <8D1421BF-F9A3-4716-BCB0-803438C7E3E8>.<1> finished with error - code: -1009
//                Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline."
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
