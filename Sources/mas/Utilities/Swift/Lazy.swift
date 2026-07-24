//
// Lazy.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import os

final class Lazy<Value: Sendable>: Sendable {
	private enum State {
		case uninitialized(@Sendable () -> Value)
		case initialized(Value)
	}

	private let stateGate: OSAllocatedUnfairLock<State>

	var value: Value {
		stateGate.withLock { state in
			switch state {
			case let .uninitialized(initialize):
				let value = initialize()
				state = .initialized(value)
				return value
			case let .initialized(value):
				return value
			}
		}
	}

	init(_ initialize: @escaping @Sendable () -> Value) {
		stateGate = .init(initialState: .uninitialized(initialize))
	}

	convenience init(_ initialize: @autoclosure @escaping @Sendable () -> Value) {
		self.init(initialize)
	}

	deinit {}
}
