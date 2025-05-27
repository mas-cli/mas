//
// Info.swift
// mas
//
// Copyright © 2016 mas-cli. All rights reserved.
//

internal import ArgumentParser
private import Foundation

extension MAS {
	/// Displays detailed information about apps from the Mac App Store.
	///
	/// This command uses the public iTunes Search API to retrieve rich metadata
	/// for each specified app ID, including:
	/// - App name
	/// - Developer
	/// - Release date
	/// - Minimum OS version
	/// - Size
	/// - App Store URL
	///
	/// This can be useful when investigating apps before installing them, or
	/// when confirming information such as version compatibility or publisher.
	///
	/// > Tip:
	/// > You can combine this with `mas search` to look up the ID, and then use `mas info`
	/// > to view full details.
	///
	/// Example:
	/// ```bash
	/// mas info 497799835
	/// ```
	///
	/// Output:
	/// ```
	/// Xcode 16.0 [Free]
	/// By: Apple Inc.
	/// Released: 2024-09-16
	/// Minimum OS: 14.5
	/// Size: 2.98 GB
	/// From: https://apps.apple.com/us/app/xcode/id497799835?mt=12&uo=4
	/// ```
	///
	/// See also:
	/// [iTunes Search API](https://performance-partners.apple.com/search-api)
	struct Info: AsyncParsableCommand {
		static let configuration = CommandConfiguration(
			abstract: "Output app information from the Mac App Store"
		)

		@OptionGroup
		var appIDsOptionGroup: AppIDsOptionGroup

		/// Runs the command.
		func run() async throws {
			try await run(searcher: ITunesSearchAppStoreSearcher())
		}

		func run(searcher: AppStoreSearcher) async throws {
			try await mas.run { await run(printer: $0, searcher: searcher) }
		}

		private func run(printer: Printer, searcher: AppStoreSearcher) async {
			var spacing = ""
			for appID in appIDsOptionGroup.appIDs {
				do {
					printer.info("", AppInfoFormatter.format(app: try await searcher.lookup(appID: appID)), separator: spacing)
				} catch {
					printer.log(spacing, to: .standardError)
					printer.error(error: error)
				}
				spacing = "\n"
			}
		}
	}
}
