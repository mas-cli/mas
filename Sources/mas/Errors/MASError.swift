//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

enum MASError: Error {
	case error(String, error: (any Error)? = nil, separator: String = ":\n", separatorAndErrorReplacement: String = "")
	case noCatalogAppsFound(for: String)
	case unknownAppID(AppID)
	case unparsableURL(String)
	case unsupportedCommand(String)

	static func error(
		_ message: String,
		error: String?,
		separator: String = ":\n",
		separatorAndErrorReplacement: String = ""
	) -> Self {
		Self.error(
			message,
			error: error.map { Self.error($0) },
			separator: separator,
			separatorAndErrorReplacement: separatorAndErrorReplacement
		)
	}
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case let .error(message, error, separator, separatorAndErrorReplacement):
			"\(message)\(error.map { "\(separator)\($0)" } ?? separatorAndErrorReplacement)"
		case let .noCatalogAppsFound(searchTerm):
			"No apps found in the App Store for search term: \(searchTerm)"
		case let .unknownAppID(appID):
			"No apps found in the App Store for \(appID)"
		case let .unparsableURL(string):
			"Failed to parse URL from \(string)"
		case let .unsupportedCommand(commandName):
			"""
			\(commandName) is not supported on this macOS version due to changes in macOS
			See https://github.com/mas-cli/mas#%EF%B8%8F-known-issues
			"""
		}
	}
}
