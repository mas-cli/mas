//
//  String+FileExtension.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension String {
    /// Returns the file name before the extension.
    var fileNameWithoutExtension: String {
        (self as NSString).deletingPathExtension
    }

    /// Returns the file extension.
    var fileExtension: String {
        (self as NSString).pathExtension
    }
}
