//
// ThrowingLazy.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import os

final class ThrowingLazy<Value: Sendable>: Sendable {
	private let state: OSAllocatedUnfairLock<(value: Value?, initializer: (@Sendable () throws -> Value)?)>

	var value: Value {
		get throws {
			try state.withLock { state in
				try state.value ?? {
					let value = try state.initializer!() // swiftlint:disable:this force_unwrapping
					state.value = value
					state.initializer = nil
					return value
				}()
			}
		}
	}

	init(_ initializer: @escaping @Sendable () throws -> Value) { // swiftlint:disable:this unneeded_escaping
		state = .init(initialState: (value: nil, initializer: initializer))
	}

	convenience init(_ initializer: @autoclosure @escaping @Sendable () throws -> Value) {
		self.init(initializer)
	}

	deinit {
		// Empty
	}
}
