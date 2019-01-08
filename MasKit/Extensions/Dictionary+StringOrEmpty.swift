//
//  Dictionary+StringOrEmpty.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/7/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension Dictionary {
    func stringOrEmpty(key: Key) -> String {
        return self[key] as? String ?? ""
    }
}
