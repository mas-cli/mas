//
// AccurateOptionGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser

struct AccurateOptionGroup: ParsableArguments {
	@Flag
	private var accuracy = OutdatedAccuracy.inaccurate

	func outdatedApps(
		accurate: (Bool) async throws -> [OutdatedApp],
		inaccurate: () async throws -> [OutdatedApp]
	) async rethrows -> [OutdatedApp] {
		switch accuracy {
		case .accurate:
			try await accurate(false)
		case .accurateIgnoreUnknownApps:
			try await accurate(true)
		case .inaccurate:
			try await inaccurate()
		}
	}
}

private enum OutdatedAccuracy: String, EnumerableFlag {
	case accurate // swiftlint:disable:previous one_declaration_per_file
	case accurateIgnoreUnknownApps
	case inaccurate

	static func help(for outdatedAccuracy: Self) -> ArgumentHelp? {
		switch outdatedAccuracy {
		case .accurate:
			"""
			Use accurate, slower logic that starts then cancels a download for each queried app, which can exceed download\
			 limits & which will open dialogs for undownloadable apps
			"""
		case .accurateIgnoreUnknownApps:
			"Use --accurate logic, but ignore apps that are unknown to the App Store"
		case .inaccurate:
			"Use inaccurate, faster logic that avoids dialogs & that ignores apps that are unknown to the App Store"
		}
	}
}
