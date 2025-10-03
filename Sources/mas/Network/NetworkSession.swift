//
// NetworkSession.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

internal import Foundation

protocol NetworkSession {
	func data(from url: URL) async throws -> (Data, URLResponse)
}
