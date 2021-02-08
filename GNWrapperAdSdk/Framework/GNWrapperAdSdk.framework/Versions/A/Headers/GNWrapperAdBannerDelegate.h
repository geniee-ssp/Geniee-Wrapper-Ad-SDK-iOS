//
//  GNWrapperAdBannerDelegate.h
//  GNWrapperAdSdk
//

#import "GNCustomTargetingParams.h"
#import "GNWrapperAdBanner.h"

@class GNWrapperAdBanner;

/// Notify to app.
@protocol GNWrapperAdBannerDelegate<NSObject>

@optional

- (void)onComplete:(GNWrapperAdBanner*)view params:(GNCustomTargetingParams*)params;

- (void)onError:(GNWrapperAdBanner*)view error:(NSError*)error;

@end
