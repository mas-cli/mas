//
//  CwlDarwinDefinitions.swift
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

import Darwin

#if arch(x86_64)
	
	// From /usr/include/mach/message.h
	// #define MACH_MSG_TYPE_MAKE_SEND		20	/* Must hold receive right */
	// #define	MACH_MSGH_BITS_REMOTE(bits)				\
	// 		((bits) & MACH_MSGH_BITS_REMOTE_MASK)
	// #define MACH_MSGH_BITS(remote, local)  /* legacy */		\
	// 		((remote) | ((local) << 8))
	public let MACH_MSG_TYPE_MAKE_SEND: UInt32 = 20
	public func MACH_MSGH_BITS_REMOTE(_ bits: UInt32) -> UInt32 { return bits & UInt32(MACH_MSGH_BITS_REMOTE_MASK) }
	public func MACH_MSGH_BITS(_ remote: UInt32, _ local: UInt32) -> UInt32 { return ((remote) | ((local) << 8)) }
	
	// From /usr/include/mach/exception_types.h
	// #define EXC_BAD_INSTRUCTION	2	/* Instruction failed */
	// #define EXC_MASK_BAD_INSTRUCTION	(1 << EXC_BAD_INSTRUCTION)
	public let EXC_BAD_INSTRUCTION: UInt32 = 2
	public let EXC_MASK_BAD_INSTRUCTION: UInt32 = 1 << EXC_BAD_INSTRUCTION
	
	// From /usr/include/mach/i386/thread_status.h
	// #define x86_THREAD_STATE64_COUNT	((mach_msg_type_number_t) \
	//		( sizeof (x86_thread_state64_t) / sizeof (int) ))
	public let x86_THREAD_STATE64_COUNT = UInt32(MemoryLayout<x86_thread_state64_t>.size / MemoryLayout<Int32>.size)
	
	public let EXC_TYPES_COUNT = 14
	public struct execTypesCountTuple<T: ExpressibleByIntegerLiteral> {
		// From /usr/include/mach/i386/exception.h
		// #define EXC_TYPES_COUNT 14 /* incl. illegal exception 0 */
		public var value: (T, T, T, T, T, T, T, T, T, T, T, T, T, T) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		public init() {
		}
	}
	
#endif
