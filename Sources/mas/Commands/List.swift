//
//  List.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
	/// Command which lists all installed apps.
	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List apps installed from the Mac App Store"
		)

		/// Runs the command.
		func run() async throws {
			try run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) throws {
			if installedApps.isEmpty {
				printError(
					"""
					No installed apps found

					If this is unexpected, the following command line should fix it by
					(re)creating the Spotlight index (which might take some time):

					sudo mdutil -Eai on
					"""
				)
			} else {
				print(AppListFormatter.format(installedApps))
			}
		}
	}
}
