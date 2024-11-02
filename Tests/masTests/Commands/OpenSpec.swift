//
//  OpenSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class OpenSpec: QuickSpec {
    override public func spec() {
        let searcher = MockAppStoreSearcher()

        beforeSuite {
            MAS.initialize()
        }
        describe("open command") {
            beforeEach {
                searcher.reset()
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Open.parse(["999"]).run(searcher: searcher)
                }
                .to(throwError(MASError.unknownAppID(999)))
            }
        }
    }
}
