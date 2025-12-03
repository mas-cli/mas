//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

enum MASError: Error {
	case noCatalogAppsFound(for: String)
	case runtimeError(String, error: (any Error)? = nil)
	case unknownAppID(AppID)
	case unsupportedCommand(String)
	case urlParsing(String)

	static func runtimeError(_ message: String, error: String) -> Self {
		runtimeError(message, error: runtimeError(error))
	}
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case let .noCatalogAppsFound(searchTerm):
			"No apps found in the App Store for search term: \(searchTerm)"
		case let .runtimeError(message, error):
			"\(message)\(error.map { ":\n\($0)" } ?? "")"
		case let .unknownAppID(appID):
			"No apps found in the App Store for \(appID)"
		case let .unsupportedCommand(commandName):
			"""
			\(commandName) is not supported on this macOS version due to changes in macOS
			See https://github.com/mas-cli/mas#known-issues
			"""
		case let .urlParsing(string):
			"Unable to parse URL from \(string)"
		}
	}
}
