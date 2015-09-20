//
//  Version.swift
//  mas-cli
//
//  Created by Andrew Naylor on 20/09/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

struct VersionCommand: CommandType {
    let verb = "version"
    let function = "Display version information about the tool"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let plist = NSBundle.mainBundle().infoDictionary
            if let versionString = plist?["CFBundleShortVersionString"] {
                print(versionString)
            }
        default:
            break
        }
        return .Success(())
    }
}
