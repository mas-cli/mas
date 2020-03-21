//
//  NetworkManagerTests.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit
import XCTest

class NetworkManagerTests: XCTestCase {
    func testSuccessfulAsyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        var result: NetworkResult!
        manager.loadData(from: url) { result = $0 }
        XCTAssertEqual(result, NetworkResult.success(data))
    }

    func testSuccessfulSyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        // Create data and tell the session to always return it
        let data = Data([0, 1, 0, 1])
        session.data = data

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        let result = manager.loadDataSync(from: url)
        XCTAssertEqual(result, NetworkResult.success(data))
    }

    func testFailureAsyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = NetworkManager.NetworkError.timeout

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        var result: NetworkResult!
        manager.loadData(from: url) { result = $0 }
        XCTAssertEqual(result, NetworkResult.failure(NetworkManager.NetworkError.timeout))
    }

    func testFailureSyncResponse() {
        // Setup our objects
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)

        session.error = NetworkManager.NetworkError.timeout

        // Create a URL (using the file path API to avoid optionals)
        let url = URL(fileURLWithPath: "url")

        // Perform the request and verify the result
        let result = manager.loadDataSync(from: url)
        XCTAssertEqual(result, NetworkResult.failure(NetworkManager.NetworkError.timeout))
    }
}
