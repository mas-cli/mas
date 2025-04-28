//
//  MAS.swift
//  mas
//
//  Created by Chris Araman on 4/22/21.
//  Copyright © 2021 mas-cli. All rights reserved.
//

import ArgumentParser

@main
struct MAS: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Mac App Store command-line interface",
		subcommands: [
			Account.self,
			Config.self,
			Home.self,
			Info.self,
			Install.self,
			List.self,
			Lucky.self,
			Open.self,
			Outdated.self,
			Purchase.self,
			Region.self,
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
}
