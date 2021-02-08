//
//  Util.m
//  GNWrapperAdSampleApp
//

#include "Util.h"
#import <AdSupport/ASIdentifierManager.h>
#include <CommonCrypto/CommonDigest.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation Util

+ (NSString *)admobDeviceID {
    NSUUID* adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    const char *cStr = [adid.UUIDString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest );

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return  output;
}

+ (void)checkIdfa {
    if (@available(iOS 14.0, *)) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    NSLog(@"checkIdfa: authorized");
                } else if (status == ATTrackingManagerAuthorizationStatusDenied) {
                    NSLog(@"checkIdfa: denied");
                } else {
                    NSLog(@"checkIdfa: something else");
                }
                dispatch_semaphore_signal(semaphore);
        }];
        // Wait until there is a reply.
        float INTERVAL_TIME = 0.01f;
        while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:INTERVAL_TIME]];
        }
    }
}

@end
