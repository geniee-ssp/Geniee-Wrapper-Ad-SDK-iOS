//
//  GNLog.h
//  GNWrapperAdSdk
//

#import <Foundation/Foundation.h>

#ifndef __GNLOGPRIORITY__
#define __GNLOGPRIORITY__
typedef enum {
    GNLogPriorityNone,
    GNLogPriorityInfo,
    GNLogPriorityWarn,
    GNLogPriorityError,
} GNLogPriority;
#endif

/**
 This class is for log of sdk.
 */
@interface GNLog : NSObject

+ (void)setPriority:(GNLogPriority)priority;

+ (void)logWithPriority:(GNLogPriority)priority
                message:(NSString *)logMessage;

@end
