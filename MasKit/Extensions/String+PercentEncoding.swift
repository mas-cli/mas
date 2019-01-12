//
//  String+PercentEncoding.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

public extension String {
    /// Return an URL encoded string
    var URLEncodedString: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
