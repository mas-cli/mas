//
//  NetworkManager.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

class NetworkManager {
    private let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    func loadData(from url: URL, completionHandler: @escaping (NetworkResult) -> Void) {
        session.loadData(from: url) { (data: Data?, error: Error?) in
            let result: NetworkResult = data != nil ? .success(data!) : .failure(error!)
//            let result = data.map(NetworkResult.success) ?? .failure(error)
            completionHandler(result)
        }
    }
}
