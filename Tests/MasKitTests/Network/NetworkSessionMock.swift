//
//  NetworkSessionMock
//  MasKitTests
//
//  Created by Ben Chatelain on 11/13/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
@testable import MasKit

/// Mock NetworkSession for testing.
class NetworkSessionMock: NetworkSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?

    /// Creates a mock data task
    ///
    /// - Parameters:
    ///   - url: unused
    ///   - completionHandler: Closure which is delivered both data and error properties (only one should be non-nil)
    /// - Returns: Mock data task
    func dataTask(with _: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }

    /// Immediately passes data and error to completion handler.
    ///
    /// - Parameters:
    ///   - url: unused
    ///   - completionHandler: Closure which is delivered either data or an error.
    func loadData(from _: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        completionHandler(data, error)
    }
}
