//
//  CwlMachBadInstructionHandler.h
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

#import <Foundation/Foundation.h>
#import <mach/mach.h>

NS_ASSUME_NONNULL_BEGIN

extern boolean_t mach_exc_server(mach_msg_header_t *InHeadP, mach_msg_header_t *OutHeadP);

// The request_mach_exception_raise_t struct is passed to mach_msg which assumes its exact layout. To avoid problems with different layouts, we keep the definition in C rather than Swift.
typedef struct
{
	mach_msg_header_t Head;
	/* start of the kernel processed data */
	mach_msg_body_t msgh_body;
	mach_msg_port_descriptor_t thread;
	mach_msg_port_descriptor_t task;
	/* end of the kernel processed data */
	NDR_record_t NDR;
	exception_type_t exception;
	mach_msg_type_number_t codeCnt;
	int64_t code[2];
	int flavor;
	mach_msg_type_number_t old_stateCnt;
	natural_t old_state[224];
} request_mach_exception_raise_t;

// The reply_mach_exception_raise_state_t struct is passed to mach_msg which assumes its exact layout. To avoid problems with different layouts, we keep the definition in C rather than Swift.
typedef struct
{
	mach_msg_header_t Head;
	NDR_record_t NDR;
	kern_return_t RetCode;
	int flavor;
	mach_msg_type_number_t new_stateCnt;
	natural_t new_state[224];
} reply_mach_exception_raise_state_t;

typedef struct
{
	mach_port_t exception_port;
	exception_type_t exception;
	mach_exception_data_type_t const * _Nullable code;
	mach_msg_type_number_t codeCnt;
	int32_t * _Nullable flavor;
	natural_t const * _Nullable old_state;
	mach_msg_type_number_t old_stateCnt;
	thread_state_t _Nullable new_state;
	mach_msg_type_number_t * _Nullable new_stateCnt;
} bad_instruction_exception_reply_t;

NS_ASSUME_NONNULL_END
