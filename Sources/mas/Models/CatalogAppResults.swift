//
// CatalogAppResults.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import JSONAST
private import JSONDecoding

struct CatalogAppResults: JSONDecodable {
	let resultCount: Int // periphery:ignore
	let resultObjects: [JSON.Object]

	private let _results: ThrowingLazy<[CatalogApp]>

	var results: [CatalogApp] { // periphery:ignore
		get throws { // swiftlint:disable:previous unused_declaration
			try _results.value
		}
	}

	init(json: JSON.Node) throws {
		guard case let .object(object) = json else {
			throw MASError.invalidJSON(.init(json))
		}

		resultCount = try object["resultCount"]?.decode() ?? 0
		resultObjects = if case let .array(array) = object[nodeKey: "results"] {
			try array.elements.map { element in
				guard case let .object(object) = element else {
					throw MASError.invalidJSON(.init(json))
				}

				return object
			}
		} else {
			.init()
		}

		let resultObjects = resultObjects
		_results = .init(try resultObjects.map { try CatalogApp(json: .object($0)) })
	}
}
