#import "NMBStringify.h"

#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif

NSString *_Nonnull NMBStringify(id _Nullable anyObject) {
    return [NMBStringer stringify:anyObject];
}
