//
//  Mas.swift
//  mas
//
//  Created by Chris Araman on 4/22/21.
//  Copyright © 2021 mas-cli. All rights reserved.
//

import ArgumentParser
import PromiseKit

@main
struct Mas: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Mac App Store command-line interface",
        subcommands: [
            Account.self,
            Home.self,
            Info.self,
            Install.self,
            List.self,
            Lucky.self,
            Open.self,
            Outdated.self,
            Purchase.self,
            Reset.self,
            Search.self,
            SignIn.self,
            SignOut.self,
            Uninstall.self,
            Upgrade.self,
            Vendor.self,
            Version.self,
        ]
    )

    func validate() throws {
        Mas.initialize()
    }

    static func initialize() {
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
