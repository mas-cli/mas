//
//  NetworkManagerTests.swift
//  masTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import XCTest

@testable import mas

class NetworkManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Mas.initialize()
    }

    func testSuccessfulAsyncResponse() throws {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        let response = try manager.loadData(from: url).wait()
        XCTAssertEqual(response, data)
    }

    func testSuccessfulSyncResponse() throws {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        let result = try manager.loadData(from: url).wait()
        XCTAssertEqual(result, data)
    }

    func testFailureAsyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = MASError.noData

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        XCTAssertThrowsError(try manager.loadData(from: url).wait()) { error in
            guard let masError = error as? MASError else {
                XCTFail("Error is of unexpected type.")
                return
            }

            XCTAssertEqual(masError, MASError.noData)
        }
    }

    func testFailureSyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = MASError.noData

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        XCTAssertThrowsError(try manager.loadData(from: url).wait()) { error in
            guard let error = error as? MASError else {
                XCTFail("Error is of unexpected type.")
                return
            }

            XCTAssertEqual(error, MASError.noData)
        }
    }
}
