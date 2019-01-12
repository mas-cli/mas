//
//  Bundle+JSON.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension Bundle {
    /// Locates a JSON response file from the test bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    static func jsonResponse(fileName: String) -> URL? {
        return Bundle(for: NetworkSessionMock.self).fileURL(fileName: fileName)
    }

    /// Builds a URL for a file in the JSON directory of the current bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    func fileURL(fileName: String) -> URL? {
        guard let path = self.path(forResource: fileName.fileNameWithoutExtension,
                                   ofType: fileName.fileExtension,
                                   inDirectory: "JSON")
            else { fatalError("Unable to load file \(fileName)") }

        return URL(fileURLWithPath: path)
    }
}
