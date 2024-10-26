//
//  Bundle+JSON.swift
//  masTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension Data {
    /// Unsafe initializer for loading data from string paths.
    ///
    /// - Parameter fileName: Relative path within the JSON folder
    init(from fileName: String) {
        let fileURL = Bundle.url(for: fileName)!
        try! self.init(contentsOf: fileURL, options: .mappedIfSafe)
    }
}

extension Bundle {
    /// Locates a JSON response file from the test bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    static func url(for fileName: String) -> URL? {
        // The Swift Package Manager places resources in a separate bundle from the executable.
        // https://forums.swift.org/t/swift-5-3-spm-resources-in-tests-uses-wrong-bundle-path/37051
        let bundleURL = Bundle(for: MockNetworkSession.self)
            .bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("mas_masTests.bundle")
        guard
            let bundle = Bundle(url: bundleURL),
            let url = bundle.url(for: fileName)
        else {
            fatalError("Unable to load file \(fileName)")
        }

        return url
    }

    /// Builds a URL for a file in the JSON directory of the current bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    private func url(for fileName: String) -> URL? {
        url(
            forResource: fileName.fileNameWithoutExtension,
            withExtension: fileName.fileExtension,
            subdirectory: "JSON"
        )
    }
}
