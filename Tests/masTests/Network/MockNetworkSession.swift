//
//  MockNetworkSession
//  masTests
//
//  Created by Ben Chatelain on 11/13/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

@testable import mas

/// Mock NetworkSession for testing.
struct MockNetworkSession: NetworkSession {
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    private let data: Data?
    private let error: Error?

    init(data: Data) {
        self.data = data
        error = nil
    }

    init(error: Error) {
        self.error = error
        data = nil
    }

    func loadData(from _: URL) -> Promise<Data> {
        guard let data else {
            return Promise(error: error ?? MASError.noData)
        }

        return .value(data)
    }
}
