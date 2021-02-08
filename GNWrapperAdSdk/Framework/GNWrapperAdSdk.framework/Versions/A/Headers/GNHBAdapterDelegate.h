//
//  GNHBAdapterDelegate.h
//  GNWrapperAdSdk
//

#include "GNHBParams.h"

/// Notify to GNHeaderBidding.
@protocol GNHBAdapterDelegate<NSObject>

@optional

- (void)onHBComplete:(GNHBParams *)params;

- (void)onHBError;

@end
