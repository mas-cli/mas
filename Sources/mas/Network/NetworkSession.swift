//
//  NetworkSession.swift
//  mas
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

protocol NetworkSession {
    func loadData(from url: URL) -> Promise<Data>
}
