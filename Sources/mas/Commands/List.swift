//
// List.swift
// mas
//
// Created by Andrew Naylor on 2015-08-21.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

internal import ArgumentParser

extension MAS {
	/// Lists all apps installed from the Mac App Store.
	struct List: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "List all apps installed from the Mac App Store"
		)

		/// Runs the command.
		func run() async {
			run(installedApps: await installedApps)
		}

		func run(installedApps: [InstalledApp]) {
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
				printInfo(AppListFormatter.format(installedApps))
			}
		}
	}
}
