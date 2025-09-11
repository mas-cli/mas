//
// AppListFormatterSpec.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
internal import Quick

final class AppListFormatterSpec: QuickSpec {
	override static func spec() {
		// Static func reference
		let format = AppListFormatter.format(_:)

		describe("app list formatter") {
			it("formats nothing as empty string") {
				expect(consequencesOf(format([]))) == ValuedConsequences("")
			}
			it("can format a single installed app") {
				let installedApp = InstalledApp(
					id: 12345,
					bundleID: "",
					name: "Awesome App",
					path: "",
					version: "19.2.1"
				)
				expect(consequencesOf(format([installedApp]))) == ValuedConsequences("12345       Awesome App  (19.2.1)")
			}
			it("can format two installed apps") {
				expect(
					consequencesOf(
						format(
							[
								InstalledApp(
									id: 12345,
									bundleID: "",
									name: "Awesome App",
									path: "",
									version: "19.2.1"
								),
								InstalledApp(
									id: 67890,
									bundleID: "",
									name: "Even Better App",
									path: "",
									version: "1.2.0"
								),
							]
						)
					)
				)
					== ValuedConsequences("12345       Awesome App      (19.2.1)\n67890       Even Better App  (1.2.0)")
			}
		}
	}
}
