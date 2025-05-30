//
// UninstallSpec.swift
// masTests
//
// Copyright © 2018 mas-cli. All rights reserved.
//

@testable private import mas
private import Nimble
import Quick

final class UninstallSpec: QuickSpec {
	override static func spec() {
		let appID = 12345 as AppID
		let app = InstalledApp(
			id: appID,
			bundleID: "com.some.app",
			name: "Some App",
			path: "/tmp/Some.app",
			version: "1.0"
		)

		xdescribe("uninstall command") {
			context("dry run") {
				it("can't remove a missing app") {
					expect(
						consequencesOf(
							try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: [])
						)
					)
						== UnvaluedConsequences(nil, "No installed apps with app ID \(appID)")
				}
				it("finds an app") {
					expect(
						consequencesOf(
							try MAS.Uninstall.parse(["--dry-run", String(appID)]).run(installedApps: [app])
						)
					)
						== UnvaluedConsequences(nil, "==> 'Some App' '/tmp/Some.app'\n==> (not removed, dry run)\n")
				}
			}
			context("wet run") {
				it("can't remove a missing app") {
					expect(
						consequencesOf(
							try MAS.Uninstall.parse([String(appID)]).run(installedApps: [])
						)
					)
						== UnvaluedConsequences(nil, "No installed apps with app ID \(appID)")
				}
				it("removes an app") {
					expect(
						consequencesOf(
							try MAS.Uninstall.parse([String(appID)]).run(installedApps: [app])
						)
					)
						== UnvaluedConsequences()
				}
			}
		}
	}
}
