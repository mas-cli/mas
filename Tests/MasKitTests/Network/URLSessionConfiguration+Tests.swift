//
//  URLSessionConfiguration+Test.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Configuration for network requests initiated from tests.
extension URLSessionConfiguration {
    /// Just like defaultSessionConfiguration, returns a
    /// newly created session configuration object, customised
    /// from the default to your requirements.
    class func testSessionConfiguration() -> URLSessionConfiguration {
        let config = `default`

        // Eg we think 60s is too long a timeout time.
        config.timeoutIntervalForRequest = 20

        // Some headers that are common to all reqeuests.
        // Eg my backend needs to be explicitly asked for JSON.
        config.httpAdditionalHeaders = ["MyResponseType": "JSON"]

        // Eg we want to use pipelining.
        config.httpShouldUsePipelining = true

        return config
    }
}
