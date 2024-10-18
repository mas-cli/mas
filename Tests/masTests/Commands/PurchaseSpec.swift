//
//  PurchaseSpec.swift
//  masTests
//
//  Created by Maximilian Blochberger on 2020-03-21.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class PurchaseSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        xdescribe("purchase command") {
            xit("purchases apps") {
                expect {
                    try Mas.Purchase.parse(["999"]).run(appLibrary: AppLibraryMock())
                }
                .toNot(throwError())
            }
        }
    }
}
