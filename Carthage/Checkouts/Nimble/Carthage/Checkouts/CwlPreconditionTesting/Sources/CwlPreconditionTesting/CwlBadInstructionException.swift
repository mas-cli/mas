//
//  CwlBadInstructionException.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 2016/01/10.
//  Copyright © 2016 Matt Gallagher ( https://www.cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

#if (os(macOS) || os(iOS)) && arch(x86_64)

import Foundation

#if canImport(NimbleCwlMachBadInstructionHandler)
import NimbleCwlMachBadInstructionHandler
#endif

private func raiseBadInstructionException() {
	BadInstructionException().raise()
}

/// A simple NSException subclass. It's not required to subclass NSException (since the exception type is represented in the name) but this helps for identifying the exception through runtime type.
@objc(BadInstructionException)
public class BadInstructionException: NSException {
	static var name: String = "com.cocoawithlove.BadInstruction"
	
	init() {
		super.init(name: NSExceptionName(rawValue: BadInstructionException.name), reason: nil, userInfo: nil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/// An Objective-C callable function, invoked from the `mach_exc_server` callback function `catch_mach_exception_raise_state` to push the `raiseBadInstructionException` function onto the stack.
	@objc(receiveReply:)
	public class func receiveReply(_ value: NSValue) -> NSNumber {
		var reply = bad_instruction_exception_reply_t(exception_port: 0, exception: 0, code: nil, codeCnt: 0, flavor: nil, old_state: nil, old_stateCnt: 0, new_state: nil, new_stateCnt: nil)
		withUnsafeMutablePointer(to: &reply) { value.getValue(UnsafeMutableRawPointer($0)) }
		
		let old_state: UnsafePointer<natural_t> = reply.old_state!
		let old_stateCnt: mach_msg_type_number_t = reply.old_stateCnt
		let new_state: thread_state_t = reply.new_state!
		let new_stateCnt: UnsafeMutablePointer<mach_msg_type_number_t> = reply.new_stateCnt!
		
		// Make sure we've been given enough memory
		if old_stateCnt != x86_THREAD_STATE64_COUNT || new_stateCnt.pointee < x86_THREAD_STATE64_COUNT {
			return NSNumber(value: KERN_INVALID_ARGUMENT)
		}
		
		// Read the old thread state
		var state = old_state.withMemoryRebound(to: x86_thread_state64_t.self, capacity: 1) { return $0.pointee }
		
		// 1. Decrement the stack pointer
		state.__rsp -= __uint64_t(MemoryLayout<Int>.size)
		
		// 2. Save the old Instruction Pointer to the stack.
		if let pointer = UnsafeMutablePointer<__uint64_t>(bitPattern: UInt(state.__rsp)) {
			pointer.pointee = state.__rip
		} else {
			return NSNumber(value: KERN_INVALID_ARGUMENT)
		}
		
		// 3. Set the Instruction Pointer to the new function's address
		var f: @convention(c) () -> Void = raiseBadInstructionException
		withUnsafePointer(to: &f) {
			state.__rip = $0.withMemoryRebound(to: __uint64_t.self, capacity: 1) { return $0.pointee }
		}
		
		// Write the new thread state
		new_state.withMemoryRebound(to: x86_thread_state64_t.self, capacity: 1) { $0.pointee = state }
		new_stateCnt.pointee = x86_THREAD_STATE64_COUNT
		
		return NSNumber(value: KERN_SUCCESS)
	}
}

#endif
