//
//  Bundle+JSON.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension Data {
    /// Unsafe initializer for loading data from string paths.
    /// - Parameter file: Relative path within the JSON folder
    init(from fileName: String) {
        let fileURL = Bundle.url(for: fileName)!
        print("fileURL: \(fileURL)")
        try! self.init(contentsOf: fileURL, options: .mappedIfSafe)
    }
}

extension Bundle {
    /// Locates a JSON response file from the test bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    static func url(for fileName: String) -> URL? {
        var bundle = Bundle(for: NetworkSessionMock.self)
        #if SWIFT_PACKAGE
        // The Swift Package Manager places resources in a separate bundle from the executable.
        bundle =
            Bundle(url: bundle.bundleURL.deletingLastPathComponent().appendingPathComponent("mas_MasKitTests.bundle"))!
        #endif
        return bundle.url(for: fileName)
    }

    /// Builds a URL for a file in the JSON directory of the current bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    func url(for fileName: String) -> URL? {
        guard
            let url = self.url(
                forResource: fileName.fileNameWithoutExtension,
                withExtension: fileName.fileExtension,
                subdirectory: "JSON"
            )
        else { fatalError("Unable to load file \(fileName)") }

        return url
    }
}
