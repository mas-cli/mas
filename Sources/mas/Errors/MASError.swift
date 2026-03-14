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
	case unparsableJSON(String? = nil)
	case unparsableURL(String)

	static func error(
		_ message: String,
		error: String?,
		separator: String = ":\n",
		separatorAndErrorReplacement: String = "",
	) -> Self {
		.error(
			message,
			error: error.map { Self.error($0) },
			separator: separator,
			separatorAndErrorReplacement: separatorAndErrorReplacement,
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
		case let .unparsableJSON(string):
			string.map { "Failed to parse JSON from:\n\($0)" } ?? "Failed to parse JSON"
		case let .unparsableURL(string):
			"Failed to parse URL from \(string)"
		}
	}
}
