//
//  CwlCatchBadInstructionPosix.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 8/02/2016.
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

#if arch(x86_64)

import Foundation

// This file is an alternative implementation to CwlCatchBadInstruction.swift that uses a SIGILL signal action and setenv/longjmp instead of a Mach exception handler and Objective-C exception raising.
//
// WARNING:
// This code is quick and dirty. It's a proof of concept for using a SIGILL handler and setjmp/longjmp where Mach exceptions and the Obj-C runtime aren't available. I ran the automated tests when I first wrote this code but I don't personally use it at all so by the time you're reading this comment, it probably broke and I didn't notice.
// Obvious limitations:
//  * It doesn't work when debugging with lldb.
//  * It doesn't scope correctly to the thread (it's global)
//  * In violation of rules for signal handlers, it writes to the "red zone" on the stack
//  * It isn't re-entrant
//  * Plus all of the same caveats as the Mach exceptions version (doesn't play well with other handlers, probably leaks ARC memory, etc)
// Treat it like a loaded shotgun. Don't point it at your face.

// This function is called from the signal handler to shut down the thread and return 1 (indicating a SIGILL was received).
private func callThreadExit() {
	pthread_exit(UnsafeMutableRawPointer(bitPattern: 1))
}

// When called, this signal handler simulates a function call to `callThreadExit`
private func sigIllHandler(code: Int32, info: UnsafeMutablePointer<__siginfo>?, uap: UnsafeMutableRawPointer?) -> Void {
	guard let context = uap?.assumingMemoryBound(to: ucontext64_t.self) else { return }

	// 1. Decrement the stack pointer
	context.pointee.uc_mcontext64.pointee.__ss.__rsp -= __uint64_t(MemoryLayout<Int>.size)

	// 2. Save the old Instruction Pointer to the stack.
	let rsp = context.pointee.uc_mcontext64.pointee.__ss.__rsp
	if let ump = UnsafeMutablePointer<__uint64_t>(bitPattern: UInt(rsp)) {
		ump.pointee = rsp
	}

	// 3. Set the Instruction Pointer to the new function's address
	var f: @convention(c) () -> Void = callThreadExit
	withUnsafePointer(to: &f) {	$0.withMemoryRebound(to: __uint64_t.self, capacity: 1) { ptr in
		context.pointee.uc_mcontext64.pointee.__ss.__rip = ptr.pointee
	} }
}

/// Without Mach exceptions or the Objective-C runtime, there's nothing to put in the exception object. It's really just a boolean – either a SIGILL was caught or not.
public class BadInstructionException {
}

/// Run the provided block. If a POSIX SIGILL is received, handle it and return a BadInstructionException (which is just an empty object in this POSIX signal version). Otherwise return nil.
/// NOTE: This function is only intended for use in test harnesses – use in a distributed build is almost certainly a bad choice. If a SIGILL is received, the block will be interrupted using a C `longjmp`. The risks associated with abrupt jumps apply here: most Swift functions are *not* interrupt-safe. Memory may be leaked and the program will not necessarily be left in a safe state.
/// - parameter block: a function without parameters that will be run
/// - returns: if an SIGILL is raised during the execution of `block` then a BadInstructionException will be returned, otherwise `nil`.
public func catchBadInstruction(block: @escaping () -> Void) -> BadInstructionException? {
	// Construct the signal action
	var sigActionPrev = sigaction()
	let action = __sigaction_u(__sa_sigaction: sigIllHandler)
	var sigActionNew = sigaction(__sigaction_u: action, sa_mask: sigset_t(), sa_flags: SA_SIGINFO)
	
	// Install the signal action
	if sigaction(SIGILL, &sigActionNew, &sigActionPrev) != 0 {
		fatalError("Sigaction error: \(errno)")
	}
	
	defer {
		// Restore the previous signal action
		if sigaction(SIGILL, &sigActionPrev, nil) != 0 {
			fatalError("Sigaction error: \(errno)")
		}
	}

	var b = block
	let caught: Bool = withUnsafeMutablePointer(to: &b) { blockPtr in
		// Run the block on its own thread
		var handlerThread: pthread_t? = nil
		let e = pthread_create(&handlerThread, nil, { arg in
			(arg.assumingMemoryBound(to: (() -> Void).self).pointee)()
			return nil
		}, blockPtr)
		precondition(e == 0, "Unable to create thread")

		// Wait for completion and get the result. It will be either `nil` or bitPattern 1
		var rawResult: UnsafeMutableRawPointer? = nil
		let e2 = pthread_join(handlerThread!, &rawResult)
		precondition(e2 == 0, "Thread join failed")
		return Int(bitPattern: rawResult) != 0
	}
	
	return caught ? BadInstructionException() : nil
}

#endif
