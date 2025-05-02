//
// Data.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-05.
// Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

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
	) {
		try! self.init(
			contentsOf: Bundle.module.url(forResource: resourcePath, withExtension: ext, subdirectory: subfolderPath)!,
			options: .mappedIfSafe
		)
	}
}
