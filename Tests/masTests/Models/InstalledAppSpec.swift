//
// InstalledAppSpec.swift
// masTests
//
// Copyright © 2021 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
internal import Quick

final class InstalledAppSpec: QuickSpec {
	override static func spec() {
		let app = InstalledApp(
			id: 111,
			bundleID: "",
			name: "App",
			path: "",
			version: "1.0.0"
		)

		describe("installed app") {
			it("is not outdated when there is no new version available") {
				expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "1.0.0")))) == ValuedConsequences(false)
			}
			it("is outdated when there is a new version available") {
				expect(consequencesOf(app.isOutdated(comparedTo: SearchResult(version: "2.0.0")))) == ValuedConsequences(true)
			}
			it("is not outdated when the new version of mac-software requires a higher OS version") {
				expect(
					consequencesOf(
						app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0"))
					)
				)
					== ValuedConsequences(false)
			}
			it("is not outdated when the new version of software requires a higher OS version") {
				expect(
					consequencesOf(
						app.isOutdated(comparedTo: SearchResult(minimumOsVersion: "99.0.0", version: "3.0.0"))
					)
				)
					== ValuedConsequences(false)
			}
		}
	}
}
