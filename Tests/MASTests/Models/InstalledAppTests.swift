//
// InstalledAppTests.swift
// mas
//
// Copyright © 2021 mas-cli. All rights reserved.
//

@testable private import MAS
internal import Testing

private let app = InstalledApp(adamID: 111, bundleID: "", name: "App", path: "", version: "1.0.0")

@Test
func installedAppNotOutdatedWhenNoNewVersionAvailable() {
	#expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "1.0.0"))) == Consequences(false))
}

@Test
func installedAppOutdatedWhenNewVersionAvailable() {
	#expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "2.0.0"))) == Consequences(true))
}

@Test
func installedAppNotOutdatedWhenNewVersionRequiresNewerMacOSVersion() {
	#expect(
		consequencesOf(app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0")))
		== Consequences(false) // swiftformat:disable:this indent
	)
}
