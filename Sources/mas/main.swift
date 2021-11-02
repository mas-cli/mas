//
//  main.swift
//  mas-cli
//
//  Created by Andrew Naylor on 11/07/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Foundation
import MasKit

MasKit.initialize()

let monterey = OperatingSystemVersion(majorVersion: 12, minorVersion: 0, patchVersion: 0)
if ProcessInfo.processInfo.isOperatingSystemAtLeast(monterey) {
    printWarning(
        "mas is not yet functional on macOS Monterey (12) due to changes in macOS frameworks. "
            + "To track progress or to *contribute* to fixing this issue, please see: "
            + "https://github.com/mas-cli/mas/issues/417")
}

let registry = CommandRegistry<MASError>()
let helpCommand = HelpCommand(registry: registry)

registry.register(AccountCommand())
registry.register(HomeCommand())
registry.register(InfoCommand())
registry.register(InstallCommand())
registry.register(PurchaseCommand())
registry.register(ListCommand())
registry.register(LuckyCommand())
registry.register(OpenCommand())
registry.register(OutdatedCommand())
registry.register(ResetCommand())
registry.register(SearchCommand())
registry.register(SignInCommand())
registry.register(SignOutCommand())
registry.register(UninstallCommand())
registry.register(UpgradeCommand())
registry.register(VendorCommand())
registry.register(VersionCommand())
registry.register(helpCommand)

registry.main(defaultVerb: helpCommand.verb) { error in
    printError(String(describing: error))
}
