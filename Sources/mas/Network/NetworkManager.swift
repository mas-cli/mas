//
//  NetworkManager.swift
//  mas
//
//  Created by Ben Chatelain on 1/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

/// Network abstraction.
struct NetworkManager {
	private let session: NetworkSession

	/// Designated initializer.
	///
	/// - Parameter session: A networking session.
	init(session: NetworkSession = URLSession(configuration: .ephemeral)) {
		self.session = session

		// Older releases allowed URLSession to write a cache. We clean it up here.
		do {
			let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches/com.mphys.mas-cli")
			try FileManager.default.removeItem(at: url)
		} catch {
			// do nothing
		}
	}

	func loadData(from url: URL) async throws -> (Data, URLResponse) {
		try await session.loadData(from: url)
	}
}
