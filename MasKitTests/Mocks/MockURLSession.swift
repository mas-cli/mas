//
//  MockURLSession.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 11/13/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

/// Mock URLSession for testing.
// FIXME: allow mock url session to operate offline
//2019-01-04 17:20:41.741632-0800 xctest[76410:1817605] TIC TCP Conn Failed [3:0x100a67420]: 1:50 Err(50)
//2019-01-04 17:20:41.741849-0800 xctest[76410:1817605] Task <0C05E774-1CDE-48FB-9408-AFFCD12F3F60>.<3> HTTP load failed (error code: -1009 [1:50])
//2019-01-04 17:20:41.741903-0800 xctest[76410:1817605] Task <0C05E774-1CDE-48FB-9408-AFFCD12F3F60>.<3> finished with error - code: -1009
//Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline." UserInfo={NSUnderlyingError=0x100a692f0 {Error Domain=kCFErrorDomainCFNetwork Code=-1009 "(null)" UserInfo={_kCFStreamErrorCodeKey=50, _kCFStreamErrorDomainKey=1}}, NSErrorFailingURLStringKey=https://itunes.apple.com/lookup?id=803453959, NSErrorFailingURLKey=https://itunes.apple.com/lookup?id=803453959, _kCFStreamErrorDomainKey=1, _kCFStreamErrorCodeKey=50, NSLocalizedDescription=The Internet connection appears to be offline.}
//    Fatal error: 'try!' expression unexpectedly raised an error: Search failed: file /BuildRoot/Library/Caches/com.apple.xbs/Sources/swiftlang_Fall2018/swiftlang_Fall2018-1000.11.42/src/swift/stdlib/public/core/ErrorType.swift, line 184
//    2019-01-04 17:20:41.818432-0800 xctest[76410:1817499] Fatal error: 'try!' expression unexpectedly raised an error: Search failed: file /BuildRoot/Library/Caches/com.apple.xbs/Sources/swiftlang_Fall2018/swiftlang_Fall2018-1000.11.42/src/swift/stdlib/public/core/ErrorType.swift, line 184
class MockURLSession: URLSession {
    // The singleton URL session, configured to use our custom config and delegate.
    static let session = URLSession(
        configuration: URLSessionConfiguration.testSessionConfiguration(),
        // Delegate is retained by the session.
        delegate: TestURLSessionDelegate(),
        delegateQueue: OperationQueue.main)

    private let responseFile: String

    /// Initializes a mock URL session with a file for the response.
    ///
    /// - Parameter responseFile: Name of file containing JSON response body.
    init(responseFile: String) {
        self.responseFile = responseFile
    }

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?

    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }

    /// Override which returns Data from a file.
    ///
    /// - Parameter requestString: Ignored URL string
    /// - Returns: Contents of responseFile
    @objc override func requestSynchronousDataWithURLString(_ requestString: String) -> Data? {
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
    @objc override func requestSynchronousJSONWithURLString(_ requestString: String) -> Any? {
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
