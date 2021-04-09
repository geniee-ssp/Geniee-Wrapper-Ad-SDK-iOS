//
//  GNWrapperAdSdk.h
//  GNWrapperAdSdk
//

#import "GNCustomTargetingParams.h"
#import "GNLog.h"
#import "GNWrapperAdBanner.h"
#import "GNWrapperAdBannerDelegate.h"

/**
 This class is common initialize proc.
 */
@interface GNWrapperAdSDK : NSObject

+ (void)setTestMode:(bool)isEnable;
+ (bool)getTestMode;
+ (void)setLogPriority:(GNLogPriority)priority;

@end
