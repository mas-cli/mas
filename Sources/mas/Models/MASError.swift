//
// MASError.swift
// mas
//
// Copyright © 2015 mas-cli. All rights reserved.
//

enum MASError: Error {
	case error(String, cause: (any Error)? = nil, separatorWhenCause: String = ":\n", separatorWhenNoCause: String = "")
	case noCatalogAppsFound(for: String)
	case unknownAppID(AppID)
	case unparsableJSON(String? = nil)
	case unparsableURL(String)

	static func error(
		_ message: String,
		cause: String?,
		separatorWhenCause: String = ":\n",
		separatorWhenNoCause: String = "",
	) -> Self {
		.error(
			message,
			cause: cause.map { Self.error($0) }, // swiftformat:disable:this redundantStaticSelf
			separatorWhenCause: separatorWhenCause,
			separatorWhenNoCause: separatorWhenNoCause,
		)
	}
}

extension MASError: CustomStringConvertible {
	var description: String {
		switch self {
		case let .error(message, cause, separatorWhenCause, separatorWhenNoCause):
			"\(message)\(cause.map { "\(separatorWhenCause)\($0)" } ?? separatorWhenNoCause)"
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
