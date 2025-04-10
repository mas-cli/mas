//
//  NetworkSession.swift
//  mas
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

protocol NetworkSession {
    func loadData(from url: URL) async throws -> (Data, URLResponse)
}
