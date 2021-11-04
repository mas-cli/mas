//
//  main.swift
//  mas-cli
//
//  Created by Andrew Naylor on 11/07/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import MasKit

MasKit.initialize()

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
