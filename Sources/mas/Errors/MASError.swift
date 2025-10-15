//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import Foundation

enum MASError: Error {
	case cancelled
	case jsonParsing(input: String? = nil)
	case noDownloads
	case noSearchResultsFound(for: String)
	case noSellerURL(forAppID: AppID)
	case notSupported
	case runtimeError(String)
	case unknownAppID(AppID)
	case urlParsing(String)
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case .cancelled:
			"Download cancelled"
		case let .jsonParsing(input):
			input.map { "Unable to parse input as JSON:\n\($0)" } ?? "Unable to parse input as JSON"
		case .noDownloads:
			"No downloads began"
		case let .noSearchResultsFound(searchTerm):
			"No apps found in the Mac App Store for search term: \(searchTerm)"
		case let .noSellerURL(appID):
			"No seller website available for \(appID)"
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
