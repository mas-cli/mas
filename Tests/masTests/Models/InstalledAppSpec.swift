//
// InstalledAppSpec.swift
// masTests
//
// Copyright © 2021 mas-cli. All rights reserved.
//

@testable private import mas
internal import Testing

private let app = InstalledApp(id: 111, bundleID: "", name: "App", path: "", version: "1.0.0")

@Test
func installedAppNotOutdatedWhenNoNewVersionAvailable() {
	#expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "1.0.0"))) == ValuedConsequences(false))
}

@Test
func installedAppOutdatedWhenNewVersionAvailable() {
	#expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "2.0.0"))) == ValuedConsequences(true))
}

@Test
func installedAppNotOutdatedWhenNewVersionRequiresNewerMacOSVersion() {
	#expect(
		consequencesOf(app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0")))
		== ValuedConsequences(false) // swiftformat:disable:this indent
	)
}
