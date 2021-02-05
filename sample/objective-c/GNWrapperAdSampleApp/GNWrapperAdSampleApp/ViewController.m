//
//  ViewController.m
//  GNWrapperAdSampleApp
//

#import "ViewController.h"
#import "Util.h"
@import Firebase;
@import GoogleMobileAds;
#import <GNWrapperAdSdk/GNWrapperAdSDK.h>
#import <PrebidMobile/PrebidMobile-Swift.h>

// Ad Size.
#define ADMANAGER_AD_SIZE kGADAdSizeBanner
//#define ADMANAGER_AD_SIZE kGADAdSizeMediumRectangle

@interface ViewController () <GADBannerViewDelegate, GADAppEventDelegate, GNWrapperAdBannerDelegate>

@property(nonatomic, weak) FIRRemoteConfig *remoteConfig;
@property(nonatomic, retain) GNWrapperAdBanner *gnWrapperAd;
@property(nonatomic, retain) GNCustomTargetingParams *targetParams;
@property(nonatomic, strong) DFPBannerView *bannerView;

@end

@implementation ViewController

// For Firebase.
static NSString* const FIREBASE_DEFAULT_REMOTE_CONFIG = @"DefaultRemoteConfig";
static double const FIREBASE_FETCH_TIME_INTERVAL_SECONDS = 720;
static NSString* const FIREBASE_KEY_CONFIG = @"GNWrapperConfig_iOS";
//static NSString* const FIREBASE_KEY_CONFIG = @"GNWrapperConfig_iOS_Prebid";
//static NSString* const FIREBASE_KEY_CONFIG = @"GNWrapperConfig_iOS_Pubmatic";
// For GNWrapperSDK.
static const bool GNWRAPPERSDK_TEST_MODE = true;
// For AdManager.
static const bool ADMANAGER_DEVELOPER_MODE = true;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [Util checkIdfa];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initFunction];
            [self requestTargetingData];
        });
    });
}

- (void)initFunction {
    _remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
    remoteConfigSettings.minimumFetchInterval = FIREBASE_FETCH_TIME_INTERVAL_SECONDS;
    _remoteConfig.configSettings = remoteConfigSettings;
    [_remoteConfig setDefaultsFromPlistFileName:FIREBASE_DEFAULT_REMOTE_CONFIG];

    [GNWrapperAdSDK setLogPriority:GNLogPriorityInfo];
    [GNWrapperAdSDK setTestMode:GNWRAPPERSDK_TEST_MODE];
    _gnWrapperAd = [[GNWrapperAdBanner alloc] init];
    [_gnWrapperAd setHidden:true];
    [self.view addSubview:_gnWrapperAd];
    _gnWrapperAd.frame = CGRectMake(0, 0, ADMANAGER_AD_SIZE.size.width, ADMANAGER_AD_SIZE.size.height);
    _gnWrapperAd.center = CGPointMake(self.view.center.x, self.view.center.y);

    _bannerView = [[DFPBannerView alloc] initWithAdSize:ADMANAGER_AD_SIZE];
    _bannerView.delegate = self;
    _bannerView.appEventDelegate = self;
    _bannerView.rootViewController = self;
    [self.view addSubview:_bannerView];
    _bannerView.center = CGPointMake(self.view.center.x, self.view.center.y);
}

- (void)requestTargetingData {
    [_remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            [self.remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
                NSString *data = self.remoteConfig[FIREBASE_KEY_CONFIG].stringValue;
                NSLog(@"ViewController: Get data = %@", data);

                [self.gnWrapperAd initWithLoad:data delegate:self viewController:self];
            }];
        } else {
            NSString *data = self.remoteConfig[FIREBASE_KEY_CONFIG].stringValue;
            NSLog(@"ViewController: Not fetched = %@", data);

            [self.gnWrapperAd initWithLoad:data delegate:self viewController:self];
        }
    }];
}

- (void)requestAdManagerBanner {
    [_gnWrapperAd setHidden:true];
    [_bannerView setHidden:false];
    _bannerView.adUnitID = _targetParams.unitId;

    DFPRequest * request = [DFPRequest request];
    request.customTargeting = _targetParams.targetParams;
    if (ADMANAGER_DEVELOPER_MODE) {
        request.testDevices = @[[Util admobDeviceID]];
    }
    [self.bannerView loadRequest:request];
    NSLog(@"ViewController: requestAdManagerBanner");
}

- (void)reqestBanner {
    if ([_gnWrapperAd isNecessaryShow]) {
        [_gnWrapperAd setHidden:false];
        [_bannerView setHidden:true];

        [_gnWrapperAd show];
        [_gnWrapperAd requestRefresh:_gnWrapperAd];
    }
}


// GNWrapperAdBannerDelegate

- (void)onComplete:(GNWrapperAdBanner*)view params:(GNCustomTargetingParams *)params {
    _targetParams = params;
    NSLog(@"ViewController: onComplete unitid = %@",params.unitId);
    for (NSString* key in [params.targetParams allKeys]) {
        NSLog(@"ViewController: onComplete key = %@ , val = %@", key, [params.targetParams objectForKey:key]);
    }

    [self requestAdManagerBanner];
}

- (void)onError:(GNWrapperAdBanner*)view error:(NSError *)error{
    NSLog(@"ViewController: onError = %@", error.localizedDescription);
}


// GADBannerViewDelegate

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
    NSLog(@"ViewController: adViewDidReceiveAd");
    [_gnWrapperAd requestRefresh:_bannerView];
    if ([@"Prebid" isEqualToString:[_gnWrapperAd getAfterLoadedGAMBanner]]) {
        [AdViewUtils findPrebidCreativeSize:adView
                                    success:^(CGSize size) {
                                        [adView resize:GADAdSizeFromCGSize(size)];
                                    } failure:^(NSError * _Nonnull error) {
                                        [GNLog logWithPriority:GNLogPriorityError message:[NSString stringWithFormat:@"ViewController: adViewDidReceiveAd error = %@", [error localizedDescription]]];
                                    }];
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(DFPBannerView *)adView
    didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"ViewController: didFailToReceiveAdWithError: %@", [error localizedDescription]);
}


/// GADAppEventDelegate.

// Called when the banner receives an app event.
- (void)adView:(DFPBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
    NSLog(@"ViewController: didReceiveAppEvent: %@", name);
    
    if ([@"pubmaticdm" isEqualToString:name]) {
        NSLog(@"GNHBPubmaticAdapter delegate");
        [self reqestBanner];
    }
}

@end
