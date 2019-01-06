//
//  MockURLSession.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 2019-01-05.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import MasKit

/// Mock URLSession for testing.
class MockNetworkSessionFromFile: MockNetworkSession {
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
    @objc override func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let fileURL = Bundle.jsonResponse(fileName: responseFile)
            else { fatalError("Unable to load file \(responseFile)") }

        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            completionHandler(data, nil)
        } catch {
            print("Error opening file: \(error)")
            completionHandler(nil, error)
        }
    }

    /// Override which returns Data from a file.
    ///
    /// - Parameter requestString: Ignored URL string
    /// - Returns: Contents of responseFile
    @objc func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
        guard let fileURL = Bundle.jsonResponse(fileName: responseFile)
            else { fatalError("Unable to load file \(responseFile)") }

        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return data
        } catch {
            print("Error opening file: \(error)")
        }

        return nil
    }

    /// Override which returns JSON contents from a file.
    ///
    /// - Parameter requestString: Ignored URL string
    /// - Returns: Parsed contents of responseFile
    @objc func requestSynchronousJSONWithURLString(_ requestString: String) -> Any? {
        guard let data = requestSynchronousDataWithURLString(requestString)
            else { return nil }

        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                return jsonResult
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }

        return nil
    }
}
