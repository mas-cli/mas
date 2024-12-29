//
//  MockFromFileNetworkSession.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-05.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

@testable import mas

/// Mock NetworkSession for testing with saved JSON response payload files.
struct MockFromFileNetworkSession: NetworkSession {
    /// Path to response payload file relative to test bundle.
    private let responseFile: String

    /// Initializes a mock URL session with a file for the response.
    ///
    /// - Parameter responseFile: Name of file containing JSON response body.
    init(responseFile: String) {
        self.responseFile = responseFile
    }

    func loadData(from _: URL) -> Promise<Data> {
        do {
            return .value(try Data(contentsOf: Bundle.url(for: responseFile), options: .mappedIfSafe))
        } catch {
            print("Error opening file: \(error)")
            return Promise(error: error)
        }
    }
}
