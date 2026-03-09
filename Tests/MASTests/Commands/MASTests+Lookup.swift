//
// MASTests+Lookup.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `cannot lookup app info for unknown app ID`() {
		let actual = consequencesOf(try MAS.main(try MAS.Lookup.parse(["1"])) { $0.run(catalogApps: []) })
		let expected = Consequences()
		#expect(actual == expected)
	}

	@Test
	func `outputs app info`() {
		let actual = consequencesOf(
			try MAS.main(try MAS.Lookup.parse(["1"])) { command in
				command.run(
					catalogApps: [
						CatalogApp(
							adamID: 1,
							appStorePageURLString: "https://awesome.app",
							fileSizeBytes: "1000000",
							formattedPrice: "$2.00",
							minimumOSVersion: "10.14",
							name: "Awesome App",
							releaseDate: "2019-01-07T18:53:13Z",
							sellerName: "Awesome Dev",
							version: "1.0",
						),
					],
				)
			},
		)
		let expected = Consequences(
			nil,
			"""
			Awesome App 1.0 [$2.00]
			By: Awesome Dev
			Released: 2019-01-07
			Minimum OS: 10.14
			Size: 1 MB
			From: https://awesome.app

			""",
		)
		#expect(actual == expected)
	}
}
