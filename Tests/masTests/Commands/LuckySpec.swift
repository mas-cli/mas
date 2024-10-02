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

public class LuckySpec: QuickSpec {
    override public static func spec() {
        let networkSession = NetworkSessionMockFromFile(responseFile: "search/slack.json")
        let storeSearch = MasStoreSearch(networkManager: NetworkManager(session: networkSession))

        beforeSuite {
            Mas.initialize()
        }
        describe("lucky command") {
            xit("installs the first app matching a search") {
                expect {
                    try Mas.Lucky.parse(["Slack"]).run(appLibrary: AppLibraryMock(), storeSearch: storeSearch)
                }
                .toNot(throwError())
            }
        }
    }
}
