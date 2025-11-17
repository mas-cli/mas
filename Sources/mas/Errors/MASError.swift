//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import Foundation

enum MASError: Error {
	case noCatalogAppsFound(for: String)
	case notSupported
	case runtimeError(String)
	case unknownAppID(AppID)
	case urlParsing(String)
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case let .noCatalogAppsFound(searchTerm):
			"No apps found in the Mac App Store for search term: \(searchTerm)"
		case .notSupported:
			"""
			This command is not supported on this macOS version due to changes in macOS
			See https://github.com/mas-cli/mas#known-issues
			"""
		case let .runtimeError(message):
			message
		case let .unknownAppID(appID):
			"No apps found in the Mac App Store for \(appID)"
		case let .urlParsing(string):
			"Unable to parse URL from \(string)"
		}
	}
}
