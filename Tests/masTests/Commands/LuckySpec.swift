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

public final class LuckySpec: AsyncSpec {
    override public static func spec() {
        let networkSession = MockFromFileNetworkSession(responseFile: "search/slack.json")
        let searcher = ITunesSearchAppStoreSearcher(networkManager: NetworkManager(session: networkSession))

        xdescribe("lucky command") {
            it("installs the first app matching a search") {
                await expecta(
                    await consequencesOf(
                        try await MAS.Lucky.parse(["Slack"]).run(appLibrary: MockAppLibrary(), searcher: searcher)
                    )
                )
                    == (nil, "", "")
            }
        }
    }
}
