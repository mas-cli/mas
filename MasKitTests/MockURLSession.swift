//
//  MockURLSession.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 11/13/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

/// Mock URLSession for testing.
class MockURLSession: URLSession {
    private let responseFile: String

    /// Initializes a mock URL session with a file for the response.
    ///
    /// - Parameter responseFile: Name of file containing JSON response body.
    init(responseFile: String) {
        self.responseFile = responseFile
    }

    /// Override which returns JSON contents from a file.
    ///
    /// - Parameter requestString: Ignored URL string
    /// - Returns: Contents of responseFile
    @objc override func requestSynchronousJSONWithURLString(_ requestString: String) -> Any? {
        guard let fileURL = Bundle.jsonResponse(fileName: responseFile)
            else { fatalError("Unable to load file \(responseFile)") }

        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
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

extension Bundle {
    /// Locates a JSON response file from the test bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    static func jsonResponse(fileName: String) -> URL? {
        return Bundle(for: MockURLSession.self).fileURL(fileName: fileName)
    }

    /// Builds a URL for a file in the JSON directory of the current bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    func fileURL(fileName: String) -> URL? {
        guard let path = self.path(forResource: fileName.fileNameWithoutExtension, ofType: fileName.fileExtension, inDirectory: "JSON")
            else { fatalError("Unable to load file \(fileName)") }

        return URL(fileURLWithPath: path)
    }
}

extension String {
    /// Returns the file name before the extension.
    var fileNameWithoutExtension: String {
        return (self as NSString).deletingPathExtension
    }

    /// Returns the file extension.
    var fileExtension: String {
        return (self as NSString).pathExtension
    }
}
