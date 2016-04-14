//
//  main.swift
//  mas-cli
//
//  Created by Andrew Naylor on 11/07/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Foundation

public struct StderrOutputStream: OutputStreamType {
    public mutating func write(string: String) {
        fputs(string, stderr)
    }
}

let registry = CommandRegistry<MASError>()
let helpCommand = HelpCommand(registry: registry)
registry.register(AccountCommand())
registry.register(SearchCommand())
registry.register(InstallCommand())
registry.register(ListCommand())
registry.register(OutdatedCommand())
registry.register(SignInCommand())
registry.register(SignOutCommand())
registry.register(UpgradeCommand())
registry.register(VersionCommand())
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    if let sourceError = error.sourceError {
        var stderr = StderrOutputStream()
        print(sourceError.localizedDescription, toStream: &stderr)
    }
    exit(Int32(error.code))
}

