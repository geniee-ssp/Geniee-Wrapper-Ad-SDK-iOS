//
//  GNCustomTargetingParams.h
//  GNWrapperAdSdk
//

#import <Foundation/Foundation.h>

/**
 Parameters to notify to app.
 */
@interface GNCustomTargetingParams : NSObject

@property(nonatomic, copy) NSString *unitId;
@property(nonatomic, retain) NSMutableDictionary *targetParams;

@end
