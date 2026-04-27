//
// Lazy.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import os

final class Lazy<Value: Sendable>: Sendable {
	private let state: OSAllocatedUnfairLock<(value: Value?, initializer: (@Sendable () -> Value)?)>

	var value: Value {
		state.withLock { state in
			state.value ?? {
				let value = state.initializer!() // swiftlint:disable:this force_unwrapping
				state.value = value
				state.initializer = nil
				return value
			}()
		}
	}

	init(_ initializer: @escaping @Sendable () -> Value) { // swiftlint:disable:this unneeded_escaping
		state = .init(initialState: (value: nil, initializer: initializer))
	}

	convenience init(_ initializer: @autoclosure @escaping @Sendable () -> Value) {
		self.init(initializer)
	}

	deinit {
		// Empty
	}
}
