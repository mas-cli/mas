//
//  NetworkManager.swift
//  MasKit
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Network abstraction
public class NetworkManager {
    private let session: NetworkSession

    /// Designated initializer
    ///
    /// - Parameter session: A networking session.
    public init(session: NetworkSession = URLSession(configuration: .ephemeral)) {
        self.session = session

        // Older releases allowed URLSession to write a cache. We clean it up here.
        do {
            let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches/com.mphys.mas-cli")
            try FileManager.default.removeItem(at: url)
        } catch {}
    }

    /// Loads data asynchronously.
    ///
    /// - Parameters:
    ///   - url: URL to load data from.
    ///   - completionHandler: Closure where result is delivered.
    func loadData(from url: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        session.loadData(from: url, completionHandler: completionHandler)
    }

    /// Loads data synchronously.
    ///
    /// - Parameter url: URL to load data from.
    /// - Returns: The Data of the response.
    func loadDataSync(from url: URL) throws -> Data {
        var data: Data?
        var error: Error?
        let group = DispatchGroup()
        group.enter()
        session.loadData(from: url) {
            data = $0
            error = $1
            group.leave()
        }

        group.wait()

        if let error = error {
            throw error
        }

        if let data = data {
            return data
        }

        throw MASError.noData
    }
}
