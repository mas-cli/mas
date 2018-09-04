//
//  CwlCatchBadInstruction.swift
//  CwlPreconditionTesting
//
//  Created by Matt Gallagher on 2016/01/10.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
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

import Foundation

#if SWIFT_PACKAGE
	import CwlMachBadInstructionHandler
#endif

#if arch(x86_64)
	
	private enum PthreadError: Error { case code(Int32) }
	private enum MachExcServer: Error { case code(kern_return_t) }
	
	/// A quick function for converting Mach error results into Swift errors
	private func kernCheck(_ f: () -> Int32) throws {
		let r = f()
		guard r == KERN_SUCCESS else {
			throw NSError(domain: NSMachErrorDomain, code: Int(r), userInfo: nil)
		}
	}
	
	extension request_mach_exception_raise_t {
		mutating func withMsgHeaderPointer<R>(in block: (UnsafeMutablePointer<mach_msg_header_t>) -> R) -> R {
			return withUnsafeMutablePointer(to: &self) { p -> R in
				return p.withMemoryRebound(to: mach_msg_header_t.self, capacity: 1) { ptr -> R in
					return block(ptr)
				}
			}
		}
	}
	
	extension reply_mach_exception_raise_state_t {
		mutating func withMsgHeaderPointer<R>(in block: (UnsafeMutablePointer<mach_msg_header_t>) -> R) -> R {
			return withUnsafeMutablePointer(to: &self) { p -> R in
				return p.withMemoryRebound(to: mach_msg_header_t.self, capacity: 1) { ptr -> R in
					return block(ptr)
				}
			}
		}
	}
	
	/// A structure used to store context associated with the Mach message port
	private struct MachContext {
		var masks = execTypesCountTuple<exception_mask_t>()
		var count: mach_msg_type_number_t = 0
		var ports = execTypesCountTuple<mach_port_t>()
		var behaviors = execTypesCountTuple<exception_behavior_t>()
		var flavors = execTypesCountTuple<thread_state_flavor_t>()
		var currentExceptionPort: mach_port_t = 0
		var handlerThread: pthread_t? = nil
		
		static func internalMutablePointers<R>(_ m: UnsafeMutablePointer<execTypesCountTuple<exception_mask_t>>, _ c: UnsafeMutablePointer<mach_msg_type_number_t>, _ p: UnsafeMutablePointer<execTypesCountTuple<mach_port_t>>, _ b: UnsafeMutablePointer<execTypesCountTuple<exception_behavior_t>>, _ f: UnsafeMutablePointer<execTypesCountTuple<thread_state_flavor_t>>, _ block: (UnsafeMutablePointer<exception_mask_t>, UnsafeMutablePointer<mach_msg_type_number_t>,  UnsafeMutablePointer<mach_port_t>, UnsafeMutablePointer<exception_behavior_t>, UnsafeMutablePointer<thread_state_flavor_t>) -> R) -> R {
			return m.withMemoryRebound(to: exception_mask_t.self, capacity: 1) { masksPtr in
				return c.withMemoryRebound(to: mach_msg_type_number_t.self, capacity: 1) { countPtr in
					return p.withMemoryRebound(to: mach_port_t.self, capacity: 1) { portsPtr in
						return b.withMemoryRebound(to: exception_behavior_t.self, capacity: 1) { behaviorsPtr in
							return f.withMemoryRebound(to: thread_state_flavor_t.self, capacity: 1) { flavorsPtr in
								return block(masksPtr, countPtr, portsPtr, behaviorsPtr, flavorsPtr)
							}
						}
					}
				}
			}
		}
		
		mutating func withUnsafeMutablePointers<R>(in block: @escaping (UnsafeMutablePointer<exception_mask_t>, UnsafeMutablePointer<mach_msg_type_number_t>, UnsafeMutablePointer<mach_port_t>, UnsafeMutablePointer<exception_behavior_t>, UnsafeMutablePointer<thread_state_flavor_t>) -> R) -> R {
			return MachContext.internalMutablePointers(&masks, &count, &ports, &behaviors, &flavors, block)
		}
	}
	
	/// A function for receiving mach messages and parsing the first with mach_exc_server (and if any others are received, throwing them away).
	private func machMessageHandler(_ arg: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
		let context = arg.assumingMemoryBound(to: MachContext.self).pointee
		var request = request_mach_exception_raise_t()
		var reply = reply_mach_exception_raise_state_t()
		
		var handledfirstException = false
		repeat { do {
			// Request the next mach message from the port
			request.Head.msgh_local_port = context.currentExceptionPort
			request.Head.msgh_size = UInt32(MemoryLayout<request_mach_exception_raise_t>.size)
			let requestSize = request.Head.msgh_size
			try kernCheck { request.withMsgHeaderPointer { requestPtr in
				mach_msg(requestPtr, MACH_RCV_MSG | MACH_RCV_INTERRUPT, 0, requestSize, context.currentExceptionPort, 0, UInt32(MACH_PORT_NULL))
			} }
			
			// Prepare the reply structure
			reply.Head.msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(request.Head.msgh_bits), 0)
			reply.Head.msgh_local_port = UInt32(MACH_PORT_NULL)
			reply.Head.msgh_remote_port = request.Head.msgh_remote_port
			reply.Head.msgh_size = UInt32(MemoryLayout<reply_mach_exception_raise_state_t>.size)
			reply.NDR = NDR_record
			
			if !handledfirstException {
				// Use the MiG generated server to invoke our handler for the request and fill in the rest of the reply structure
				guard request.withMsgHeaderPointer(in: { requestPtr in reply.withMsgHeaderPointer { replyPtr in
					mach_exc_server(requestPtr, replyPtr)
				} }) != 0 else { throw MachExcServer.code(reply.RetCode) }
				
				handledfirstException = true
			} else {
				// If multiple fatal errors occur, don't handle subsquent errors (let the program crash)
				reply.RetCode = KERN_FAILURE
			}
			
			// Send the reply
			let replySize = reply.Head.msgh_size
			try kernCheck { reply.withMsgHeaderPointer { replyPtr in
				mach_msg(replyPtr, MACH_SEND_MSG, replySize, 0, UInt32(MACH_PORT_NULL), 0, UInt32(MACH_PORT_NULL))
			} }
		} catch let error as NSError where (error.domain == NSMachErrorDomain && (error.code == Int(MACH_RCV_PORT_CHANGED) || error.code == Int(MACH_RCV_INVALID_NAME))) {
			// Port was already closed before we started or closed while we were listening.
			// This means the controlling thread shut down.
			return nil
		} catch {
			// Should never be reached but this is testing code, don't try to recover, just abort
			fatalError("Mach message error: \(error)")
		} } while true
	}
	
	/// Run the provided block. If a mach "BAD_INSTRUCTION" exception is raised, catch it and return a BadInstructionException (which captures stack information about the throw site, if desired). Otherwise return nil.
	/// NOTE: This function is only intended for use in test harnesses – use in a distributed build is almost certainly a bad choice. If a "BAD_INSTRUCTION" exception is raised, the block will be exited before completion via Objective-C exception. The risks associated with an Objective-C exception apply here: most Swift/Objective-C functions are *not* exception-safe. Memory may be leaked and the program will not necessarily be left in a safe state.
	/// - parameter block: a function without parameters that will be run
	/// - returns: if an EXC_BAD_INSTRUCTION is raised during the execution of `block` then a BadInstructionException will be returned, otherwise `nil`.
	public func catchBadInstruction(in block: () -> Void) -> BadInstructionException? {
		var context = MachContext()
		var result: BadInstructionException? = nil
		do {
			var handlerThread: pthread_t? = nil
			defer {
				// 8. Wait for the thread to terminate *if* we actually made it to the creation point
				// The mach port should be destroyed *before* calling pthread_join to avoid a deadlock.
				if handlerThread != nil {
					pthread_join(handlerThread!, nil)
				}
			}
			
			try kernCheck {
				// 1. Create the mach port
				mach_port_allocate(mach_task_self_, MACH_PORT_RIGHT_RECEIVE, &context.currentExceptionPort)
			}
			defer {
				// 7. Cleanup the mach port
				mach_port_destroy(mach_task_self_, context.currentExceptionPort)
			}
			
			try kernCheck {
				// 2. Configure the mach port
				mach_port_insert_right(mach_task_self_, context.currentExceptionPort, context.currentExceptionPort, MACH_MSG_TYPE_MAKE_SEND)
			}
			
			let currentExceptionPtr = context.currentExceptionPort
			try kernCheck { context.withUnsafeMutablePointers { masksPtr, countPtr, portsPtr, behaviorsPtr, flavorsPtr in
				// 3. Apply the mach port as the handler for this thread
				thread_swap_exception_ports(mach_thread_self(), EXC_MASK_BAD_INSTRUCTION, currentExceptionPtr, Int32(bitPattern: UInt32(EXCEPTION_STATE) | MACH_EXCEPTION_CODES), x86_THREAD_STATE64, masksPtr, countPtr, portsPtr, behaviorsPtr, flavorsPtr)
			} }
			
			defer { context.withUnsafeMutablePointers { masksPtr, countPtr, portsPtr, behaviorsPtr, flavorsPtr in
				// 6. Unapply the mach port
				_ = thread_swap_exception_ports(mach_thread_self(), EXC_MASK_BAD_INSTRUCTION, 0, EXCEPTION_DEFAULT, THREAD_STATE_NONE, masksPtr, countPtr, portsPtr, behaviorsPtr, flavorsPtr)
			} }
			
			try withUnsafeMutablePointer(to: &context) { c throws in
				// 4. Create the thread
				let e = pthread_create(&handlerThread, nil, machMessageHandler, c)
				guard e == 0 else { throw PthreadError.code(e) }
				
				// 5. Run the block
				result = BadInstructionException.catchException(in: block)
			}
		} catch {
			// Should never be reached but this is testing code, don't try to recover, just abort
			fatalError("Mach port error: \(error)")
		}
		return result
	}
	
#endif

