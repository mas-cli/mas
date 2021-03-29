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
        Bundle(for: NetworkSessionMock.self).url(for: fileName)
    }

    /// Builds a URL for a file in the JSON directory of the current bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    func url(for fileName: String) -> URL? {
        guard
            let path = self.path(
                forResource: fileName.fileNameWithoutExtension,
                ofType: fileName.fileExtension,
                inDirectory: "JSON"
            )
        else { fatalError("Unable to load file \(fileName)") }

        return URL(fileURLWithPath: path)
    }
}
