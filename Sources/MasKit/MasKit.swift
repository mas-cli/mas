//
//  MasKit.swift
//  MasKit
//
//  Created by Chris Araman on 4/22/21.
//  Copyright © 2021 mas-cli. All rights reserved.
//

import PromiseKit

public enum MasKit {
    public static func initialize() {
        PromiseKit.conf.Q.map = .global()
        PromiseKit.conf.Q.return = .global()
        PromiseKit.conf.logHandler = { event in
            switch event {
            case .waitOnMainThread:
                // Ignored. This is a console app that waits on the main thread for
                // promises to be processed on the global DispatchQueue.
                break
            default:
                // Other events indicate a programming error.
                fatalError("PromiseKit event: \(event)")
            }
        }
    }
}
