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
        try! self.init(contentsOf: Bundle.url(for: fileName), options: .mappedIfSafe)
    }
}

extension Bundle {
    /// Locates a JSON response file from the test bundle.
    ///
    /// - Parameter fileName: Name of file to locate.
    /// - Returns: URL to file.
    static func url(for fileName: String) -> URL {
        if let url = Bundle.module.url(forResource: fileName, withExtension: nil, subdirectory: "JSON") {
            url
        } else {
            fatalError("Unable to load file \(fileName)")
        }
    }
}
