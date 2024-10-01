//
//  NetworkSessionMockFromFile.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-05.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

/// Mock NetworkSession for testing with saved JSON response payload files.
class NetworkSessionMockFromFile: NetworkSessionMock {
    /// Path to response payload file relative to test bundle.
    private let responseFile: String

    /// Initializes a mock URL session with a file for the response.
    ///
    /// - Parameter responseFile: Name of file containing JSON response body.
    init(responseFile: String) {
        self.responseFile = responseFile
    }

    /// Loads data from a file.
    ///
    /// - Parameters:
    ///   - url: unused
    ///   - completionHandler: Closure which is delivered either data or an error.
    override func loadData(from _: URL) -> Promise<Data> {
        guard let fileURL = Bundle.url(for: responseFile)
        else { fatalError("Unable to load file \(responseFile)") }

        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return .value(data)
        } catch {
            print("Error opening file: \(error)")
            return Promise(error: error)
        }
    }
}
