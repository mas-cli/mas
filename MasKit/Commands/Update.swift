//
//  Update.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Foundation

/// Command which updates mas.
public struct UpdateCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "update"
    public let function = "Update MAS"

    private let appLibrary: AppLibrary

    /// Public initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    public init() {
        self.init(appLibrary: MasAppLibrary())
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    init(appLibrary: AppLibrary = MasAppLibrary()) {
        self.appLibrary = appLibrary
    }

    /// Runs the command.
    public func run(_: Options) -> Result<(), MASError> {
        print("Updating MAS…")

        let task = Process()
        task.launchPath = getenv("HOMEBREW_BREW_FILE")
        task.arguments = ["upgrade", "mas"]
        //let pipe = Pipe()
        //task.standardOutput = pipe
        //task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
