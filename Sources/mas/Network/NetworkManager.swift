//
//  NetworkManager.swift
//  mas
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

/// Network abstraction.
class NetworkManager {
    private let session: NetworkSession

    /// Designated initializer.
    ///
    /// - Parameter session: A networking session.
    init(session: NetworkSession = URLSession(configuration: .ephemeral)) {
        self.session = session

        // Older releases allowed URLSession to write a cache. We clean it up here.
        do {
            let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches/com.mphys.mas-cli")
            try FileManager.default.removeItem(at: url)
        } catch {}
    }

    /// Loads data asynchronously.
    ///
    /// - Parameter url: URL from which to load data.
    /// - Returns: A Promise for the Data of the response.
    func loadData(from url: URL) -> Promise<Data> {
        session.loadData(from: url)
    }
}
