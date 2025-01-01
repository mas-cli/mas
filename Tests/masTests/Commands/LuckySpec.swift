//
//  LuckySpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class LuckySpec: QuickSpec {
    override public func spec() {
        let networkSession = MockFromFileNetworkSession(responseFile: "search/slack.json")
        let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

        beforeSuite {
            MAS.initialize()
        }
        xdescribe("lucky command") {
            xit("installs the first app matching a search") {
                expect {
                    try MAS.Lucky.parse(["Slack"]).run(appLibrary: MockAppLibrary(), searcher: searcher)
                }
                .toNot(throwError())
            }
        }
    }
}
