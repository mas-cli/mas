//
//  Version.swift
//  mas-cli
//
//  Created by Andrew Naylor on 20/09/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant

/// Command which displays the version of the mas tool.
public struct VersionCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "version"
    public let function = "Print version number"

    public init() {}

    /// Runs the command.
    public func run(_: Options) -> Result<(), MASError> {
        let plist = Bundle.main.infoDictionary
        if let versionString = plist?["CFBundleShortVersionString"] {
            print(versionString)
        }
        return .success(())
    }
}
