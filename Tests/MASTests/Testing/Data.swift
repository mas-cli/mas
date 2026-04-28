//
// Data.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas

extension Data {
	init(
		fromResource resourcePath: String?,
		withExtension ext: String? = "json",
		inSubfolderPath subfolderPath: String? = "",
	) throws {
		guard
			let resourceURL = Bundle.module.url(forResource: resourcePath, withExtension: ext, subdirectory: subfolderPath)
		else {
			throw MASError.error(
				"""
				Failed to find resource\
				\(resourcePath.map { " at \($0)" } ?? "")\
				\(ext.map { " with extension \($0)" } ?? "")\
				\(subfolderPath.map { " in subfolder \($0)" } ?? "")
				""",
			)
		}

		try self.init(contentsOf: resourceURL, options: .mappedIfSafe)
	}
}
