//
//  GNHBParams.h
//  GNWrapperAdSdk
//

#import <Foundation/Foundation.h>

/**
 Parameters to notify from adapter to GNHeaderBidding.
 */
@interface GNHBParams : NSObject

@property(nonatomic, retain) NSDictionary *hbRequestParams;
@property(nonatomic, copy) NSString *hbName;
@property(nonatomic, copy) NSString *bidderName;
@property(nonatomic, assign) double bidPrice;
@property(nonatomic, retain) NSDictionary *hbResponseParams;

- (void)initResponseParam;

@end
