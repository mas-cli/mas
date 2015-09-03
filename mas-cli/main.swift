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
registry.register(InstallCommand())
registry.register(ListInstalledCommand())
registry.register(ListUpdatesCommand())
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    if let sourceError = error.sourceError {
        var stderr = StderrOutputStream()
        println(sourceError.localizedDescription, &stderr)
    }
    exit(Int32(error.code))
}

