//
//  GNWrapperAdBanner.h
//  GNWrapperAdSdk
//

#import <UIKit/UIKit.h>
#import "GNWrapperAdBannerDelegate.h"

/**
 This class is to get the parameter of custom targeting info.
 */
@interface GNWrapperAdBanner : UIView

- (void)initWithLoad:(NSString *)data delegate:(id<GNWrapperAdBannerDelegate>)delegate viewController:(UIViewController*)viewController;
- (NSString*)getAfterLoadedGAMBanner;
- (bool)isNecessaryShow;
- (void)show;
- (void)requestRefresh:(UIView*)view;
- (void)clearView;

@end
