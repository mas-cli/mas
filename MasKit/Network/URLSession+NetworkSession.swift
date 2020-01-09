//
//  URLSession+NetworkSession.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

extension URLSession: NetworkSession {
    @objc open func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        let task = dataTask(with: url) { data, _, error in
            completionHandler(data, error)
        }
        task.resume()
    }
}
