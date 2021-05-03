//
//  String+PercentEncoding.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension String {
    /// Return an URL encoded string
    public var urlEncodedString: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
