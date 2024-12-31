//
//  NetworkManagerSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import XCTest

@testable import mas

class NetworkManagerSpec: XCTestCase {
    override func setUp() {
        super.setUp()
        MAS.initialize()
    }

    func testSuccessfulAsyncResponse() throws {
        let data = Data([0, 1, 0, 1])
        XCTAssertEqual(
            try NetworkManager(session: MockNetworkSession(data: data))
                .loadData(from: URL(fileURLWithPath: "url"))
                .wait(),
            data
        )
    }

    func testSuccessfulSyncResponse() throws {
        let data = Data([0, 1, 0, 1])
        XCTAssertEqual(
            try NetworkManager(session: MockNetworkSession(data: data))
                .loadData(from: URL(fileURLWithPath: "url"))
                .wait(),
            data
        )
    }

    func testFailureAsyncResponse() {
        XCTAssertThrowsError(
            try NetworkManager(session: MockNetworkSession(error: MASError.noData))
                .loadData(from: URL(fileURLWithPath: "url"))
                .wait()
        ) { error in
            guard let masError = error as? MASError else {
                XCTFail("Error is of unexpected type.")
                return
            }

            XCTAssertEqual(masError, MASError.noData)
        }
    }

    func testFailureSyncResponse() {
        XCTAssertThrowsError(
            try NetworkManager(session: MockNetworkSession(error: MASError.noData))
                .loadData(from: URL(fileURLWithPath: "url"))
                .wait()
        ) { error in
            guard let error = error as? MASError else {
                XCTFail("Error is of unexpected type.")
                return
            }

            XCTAssertEqual(error, MASError.noData)
        }
    }
}
