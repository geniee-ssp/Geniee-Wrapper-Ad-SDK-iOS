//
//  GNHBBannerAdapter.h
//  GNWrapperAdSdk
//

#import <UIKit/UIKit.h>
#import "GNHBAdapterDelegate.h"

/// Abstract class of adapter.
@protocol GNHBBannerAdapter<NSObject>

- (void)initialize:(NSDictionary *)params
           timeout:(double)timeout
          delegate:(id<GNHBAdapterDelegate>)delegate
    viewController:(UIViewController*)viewController
          testMode:(bool)isTestMode;

- (void)requestInfo;

- (bool)isAfterLoadedGAMBanner;

- (bool)isNecessaryShow;

- (void)show:(UIView*)view;

- (void)requestRefresh;

- (void)clearView;

- (NSString*)getName;

@end
