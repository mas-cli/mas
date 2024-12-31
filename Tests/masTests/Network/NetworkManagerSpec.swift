//
//  NetworkManagerSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class NetworkManagerSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("network manager") {
            it("returns data") {
                let data = Data([0, 1, 0, 1])
                expect(
                    try NetworkManager(session: MockNetworkSession(data: data))
                        .loadData(from: URL(fileURLWithPath: "url"))
                        .wait()
                )
                    == data
            }

            it("throws no data error") {
                expect(
                    try NetworkManager(session: MockNetworkSession(error: MASError.noData))
                        .loadData(from: URL(fileURLWithPath: "url"))
                        .wait()
                )
                .to(throwError(MASError.noData))
            }
        }
    }
}
