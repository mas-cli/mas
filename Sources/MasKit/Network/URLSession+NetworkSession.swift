//
//  URLSession+NetworkSession.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

extension URLSession: NetworkSession {
    public func loadData(from url: URL) -> Promise<Data> {
        Promise { seal in
            dataTask(with: url) { data, _, error in
                if let data = data {
                    seal.fulfill(data)
                } else if let error = error {
                    seal.reject(error)
                } else {
                    seal.reject(MASError.noData)
                }
            }
            .resume()
        }
    }
}
