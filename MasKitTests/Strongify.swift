//
//  Strongify.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/8/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

// https://medium.com/@merowing_/stop-weak-strong-dance-in-swift-3aec6d3563d4

func strongify<Context: AnyObject, Arguments>(_ context: Context?,
                                              closure: @escaping (Context, Arguments) -> Void) -> (Arguments) -> Void {
    return { [weak context] arguments in
        guard let strongContext = context else { return }
        closure(strongContext, arguments)
    }
}

func strongify<Context: AnyObject>(_ context: Context?, closure: @escaping (Context) -> Void) {
    guard let strongContext = context else { return }
    closure(strongContext)
}
