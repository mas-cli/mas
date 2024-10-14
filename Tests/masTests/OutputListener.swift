//
//  OutputListener.swift
//  masTests
//
//  Created by Ben Chatelain on 1/7/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import mas

/// Test helper for monitoring strings written to stdout. Modified from:
/// https://stackoverflow.com/a/53569018
class OutputListener {
    /// Buffers strings written to stdout
    var contents = ""

    init() {
        printObserver = { [weak self] text in
            strongify(self) { context in
                context.contents += text
            }
        }
    }

    deinit {
        printObserver = nil
    }
}
