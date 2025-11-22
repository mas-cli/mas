//
// Error.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

extension Error {
	func printProblem(shouldWarnIfAppUnknown: Bool, expectedAppName appName: String) {
		guard let error = self as? MASError, case MASError.unknownAppID = error else {
			MAS.printer.error(error: self)
			return
		}

		if shouldWarnIfAppUnknown {
			MAS.printer.warning(self, "; was expected to identify: ", appName, separator: "")
		}
	}
}
