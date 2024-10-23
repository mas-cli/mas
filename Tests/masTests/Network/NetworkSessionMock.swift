//
//  NetworkSessionMock
//  masTests
//
//  Created by Ben Chatelain on 11/13/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

@testable import mas

/// Mock NetworkSession for testing.
class NetworkSessionMock: NetworkSession {
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?

    func loadData(from _: URL) -> Promise<Data> {
        guard let data else {
            return Promise(error: error ?? MASError.noData)
        }

        return .value(data)
    }
}
