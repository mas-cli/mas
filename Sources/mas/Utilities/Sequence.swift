//
// Sequence.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

extension Sequence {
	func forEach<E: Error>(attemptTo effect: String, _ body: (Element) async throws(E) -> Void) async {
		await forEach(body) { MAS.printer.error($1 is MASError ? [] : ["Failed to", effect, $0], error: $1) }
	}

	private func forEach<E: Error>(
		_ body: (Element) async throws(E) -> Void,
		handlingErrors errorHandler: (Element, E) async -> Void,
	) async {
		for element in self {
			do {
				try await body(element)
			} catch {
				await errorHandler(element, error)
			}
		}
	}
}
