//
//  HomeSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class HomeSpec: QuickSpec {
    override public func spec() {
        let searcher = MockAppStoreSearcher()

        beforeSuite {
            MAS.initialize()
        }
        describe("home command") {
            beforeEach {
                searcher.reset()
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Home.parse(["999"]).run(searcher: searcher)
                }
                .to(throwError(MASError.noSearchResultsFound))
            }
        }
    }
}
