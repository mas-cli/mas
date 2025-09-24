//
// Data.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import Foundation
@testable private import MAS

extension Data {
	/// Unsafe initializer for loading data from string paths.
	///
	/// - Parameters:
	///   - resourcePath: Relative path of resource within subfolderPath
	///   - ext: Extension of the resource
	///   - subfolderPath: Relative path of folder within the module
	init(
		fromResource resourcePath: String?,
		withExtension ext: String? = nil,
		inSubfolderPath subfolderPath: String? = "Resources"
	) throws {
		guard
			let resourceURL = Bundle.module.url(forResource: resourcePath, withExtension: ext, subdirectory: subfolderPath)
		else {
			throw MASError.runtimeError( // swiftformat:disable wrapConditionalBodies
				"""
				Failed to find resource\
				\({ if let resourcePath { " at \(resourcePath)" } else { "" } }())\
				\({ if let ext { " with extension \(ext)" } else { "" } }())\
				\({ if let subfolderPath { " in subfolder \(subfolderPath)" } else { "" } }())
				""" // swiftformat:enable wrapConditionalBodies
			)
		}

		try self.init(contentsOf: resourceURL, options: .mappedIfSafe)
	}
}
