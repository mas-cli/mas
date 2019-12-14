//
//  CwlMachBadExceptionHandler.m
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

#ifdef __APPLE__
#import "TargetConditionals.h"
#if TARGET_OS_OSX || TARGET_OS_IOS

#import "mach_excServer.h"
#import "CwlMachBadInstructionHandler.h"

@protocol BadInstructionReply <NSObject>
+(NSNumber *)receiveReply:(NSValue *)value;
@end

/// A basic function that receives callbacks from mach_exc_server and relays them to the Swift implemented BadInstructionException.catch_mach_exception_raise_state.
kern_return_t catch_mach_exception_raise_state(mach_port_t exception_port, exception_type_t exception, const mach_exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, const thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt) {
	bad_instruction_exception_reply_t reply = { exception_port, exception, code, codeCnt, flavor, old_state, old_stateCnt, new_state, new_stateCnt };
	Class badInstructionClass = NSClassFromString(@"BadInstructionException");
	NSValue *value = [NSValue valueWithBytes: &reply objCType: @encode(bad_instruction_exception_reply_t)];
	return [[badInstructionClass performSelector: @selector(receiveReply:) withObject: value] intValue];
}

// The mach port should be configured so that this function is never used.
kern_return_t catch_mach_exception_raise(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt) {
	assert(false);
	return KERN_FAILURE;
}

// The mach port should be configured so that this function is never used.
kern_return_t catch_mach_exception_raise_state_identity(mach_port_t exception_port, mach_port_t thread, mach_port_t task, exception_type_t exception, mach_exception_data_t code, mach_msg_type_number_t codeCnt, int *flavor, thread_state_t old_state, mach_msg_type_number_t old_stateCnt, thread_state_t new_state, mach_msg_type_number_t *new_stateCnt) {
	assert(false);
	return KERN_FAILURE;
}
	
#endif /* TARGET_OS_OSX || TARGET_OS_IOS */
#endif /* __APPLE__ */
