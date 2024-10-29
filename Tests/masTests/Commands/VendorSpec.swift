//
//  VendorSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-03.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class VendorSpec: QuickSpec {
    override public func spec() {
        let searcher = MockAppStoreSearcher()

        beforeSuite {
            MAS.initialize()
        }
        describe("vendor command") {
            beforeEach {
                searcher.reset()
            }
            it("can't find app with unknown ID") {
                expect {
                    try MAS.Vendor.parse(["999"]).run(searcher: searcher)
                }
                .to(throwError(MASError.unknownAppID(999)))
            }
        }
    }
}
