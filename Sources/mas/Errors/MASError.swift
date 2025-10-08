//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

internal import Foundation

enum MASError: Error, Equatable {
	case cancelled
	case jsonParsing(data: Data)
	case noDownloads
	case noSearchResultsFound(for: String)
	case noVendorWebsite(forAppID: AppID)
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
		case let .jsonParsing(data):
			String(data: data, encoding: .utf8).map { "Unable to parse response as JSON:\n\($0)" }
			?? "Unable to parse response as JSON" // swiftformat:disable:this indent
		case .noDownloads:
			"No downloads began"
		case let .noSearchResultsFound(searchTerm):
			"No apps found in the Mac App Store for search term: \(searchTerm)"
		case let .noVendorWebsite(appID):
			"No vendor website available for \(appID)"
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
