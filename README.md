# GNWrapperAdSDKの実装方法について


## 概要
UPR最適化+HBによる収益向上を行うため、GNWrapperAdSDKを使用してCustomTargeting情報を取得し、GoogleAdManagerを使用して広告表示を行います。  
そのため、FirebaseのRemoteConfig機能とGoogleAdManagerを使用します。  

- FirebaseのRemoteConfig機能で広告枠情報の取得を行います。  
- 上記で取得した広告枠情報より、GNWrapperAdSDKを使用して、UnitId・CustomTargeting情報の取得を行います。  
- 上記で取得したUnitId・CustomTargeting情報より、Google AdManagerを使用して広告表示を行います。


## 実装手順
### 1. アプリのプロジェクト設定
#### 1.1. Firebase初期設定
1. Firebase管理画面よりプロジェクトを作成し、アプリの登録を行います。

2. アプリを登録する際、Firebaseへアクセスするための情報が記載されたファイル`GoogleService-Info.plist`をダウンロードする手順があるのでダウンロードします。(または、登録したアプリの設定画面よりファイルをダウンロードできます。)

3. ダウンロードしたファイル`GoogleService-Info.plist`を、アプリのプロジェクトへ追加します。  

	Firebase初期設定については以下のURLを参考にしてください。
	[FirebaseをiOSプロジェクトに追加する](https://firebase.google.com/docs/ios/setup?hl=ja)

#### 1.2. RemoteConfig初期設定
1. plistファイルを作成し、default情報(広告枠情報)について記載します。これはFirebaseのRemoteConfig機能から広告枠情報を取得できない場合に使用されます。

	広告枠情報としては以下のjson形式の文字列で指定します。
	
	| 第１階層 | 第2階層 | 型 | 概要 |
	| :-- | :-- | :-- | :-- |
	| unit_id |  | 文字列 | AdManagerで使用するUnitId。 |
	| timeout |  | 数値 | 各アダプターでの要求待ち時間(秒)。 |
	| is_refresh |  | Boolean | リフレッシュ機能の有効/無効。 |
	| refresh_interval |  | 数値 | リフレッシュ時間(秒)。 |
	| use_upr |  | Boolean | UPRの有効/無効。 |
	| upr_settings |  | Dictionary |  |
	|  | upr_key | 文字列 | UPRキー。 |
	|  | upr_value | 文字列 | UPR値。 |
	| use_hb |  | Boolean | HeaderBiddingの有効/無効。 |
	| hb_list |  | リスト |  |
	|  | hb_name | 文字列 | 使用するHB名。 |
	|  | hb_values | 文字列	 | 情報を取得する為の文字列。 |
	
	hb_name="Prebid"の場合の"hb\_values"
	
	| 第１階層 | 型 | 概要 |
	| :-- | :-- | :-- |
	| prebid_server_host_type | 文字列 | Prebid情報(server_host_type)。  <br>"APPNEXUS"<br>"RUBICON"<br>"CUSTOM" |
	| prebid_server_host_url | 文字列 | Prebid情報(server_host_url)。 |
	| prebid_server_account_id | 文字列 | Prebid情報(server_account_id)。 |
	| config_id | 文字列 | Prebid情報(config_id)。 |
	| ad_size | 文字列 | 広告サイズ。<br>幅x高さ |
	
	hb_name="Pubmatic"の場合の"hb\_value"
	
	| 第１階層 | 型 | 概要 |
	| :-- | :-- | :-- |
	| app_store_url | 文字列 | Pubmatic情報(app_store_url)。 |
	| pub_id | 文字列 | Pubmatic情報(pub_id)。 |
	| profile_id | 文字列 | Pubmatic情報(profile_id)。 |
	| open_wrap_ad_unit_id | 文字列 | Pubmatic情報(UnitId)。 |
	| ad_size | 文字列 | 広告サイズ。<br>幅x高さ |
	
	サンプルコード	
	```
	{"unit_id":"/15671365/pm_sdk/PMSDK-Demo-App-Banner","timeout":3.2,"is_refresh":true,"refresh_interval":10,"use_upr":true,"upr_settings":{"upr_key":"geniee-upr","upr_value":"prod"},"use_hb":true,"hb_list":[{"hb_name":"Prebid","hb_values":{"prebid_server_host_type":"APPNEXUS","prebid_server_host_url":"","prebid_server_account_id":"bfa84af2-bd16-4d35-96ad-31c6bb888df0","config_id":"6ace8c7d-88c0-4623-8117-75bc3f0a2e45","ad_size":"320x50"}}, {"hb_name":"Pubmatic","hb_values":{"app_store_url":"https://play.google.com/store/apps/details?id=com.example.android&hl=en","pub_id":"156276","profile_id":"1165","open_wrap_ad_unit_id":"/15671365/pm_sdk/PMSDK-Demo-App-Banner","ad_size":"320x50"}},{"hb_name":"aaaa","hb_values":{}}]}
	```
	
	Firebase RemoteConfigの初期設定については以下のURLを参考にしてください。  
	[アプリ内デフォルト パラメータ値を設定する](https://firebase.google.com/docs/remote-config/use-config-ios)

#### 1.3. Frameworkの取り込み
1. Podfileに以下の記述を追加してください。(Podfileがない場合はコマンド`pod init`で作成します)

	- Firebase

		```
		# Firebase
		pod 'Firebase/Core'
		pod 'Firebase/RemoteConfig'
		```
	- GoogleMobileAdSDK

		```
		# GoogleAdSDK
		pod 'Google-Mobile-Ads-SDK'
		```

	- GNWrapperAdSDK

		```
		# GNWrapperAdSDK
		pod 'Geniee-Wrapper-Ad-SDK-iOS'
		```
            
		GNWrapperAdSDKをローカルで取り込む場合は、"GNWrapperAdSDK.framework"をプロジェクトへ取り込み、プロジェクト設定のBuild SettingsのFramework Search Pathsの設定に"GNWrapperAdSDK.framework"のパスを指定してください。
        
	- Prebid広告を使用する場合

		```
		# Prebid
		pod 'PrebidMobile'
		# GNHBPrebidBannerAdapter
		pod 'Geniee-Wrapper-Ad-Banner-Adapter-Prebid-iOS'
		```

		GNHBPrebidBannerAdapterをローカルで取り込む場合は、"GNHBPrebidBannerAdapter.framework"をプロジェクトへ取り込み、プロジェクト設定のBuild SettingsのFramework Search Pathsの設定に"GNHBPrebidBannerAdapter.framework"のパスを指定してください。

	- Pubmatic広告を使用する場合

		```
		# PubMatic
		pod 'OpenWrapSDK'
		# GNHBPubmaticBannerAdapter
		pod 'Geniee-Wrapper-Ad-Banner-Adapter-Pubmatic-iOS'
		```

		GNHBPubmaticBannerAdapterをローカルで取り込む場合は、"GNHBPubmaticBannerAdapter.framework"をプロジェクトへ取り込み、プロジェクト設定のBuild SettingsのFramework Search Pathsの設定に"GNHBPubmaticBannerAdapter.framework"のパスを指定してください。

2. コマンド`pod install`でFrameworkをプロジェクトへ取り入れます。

#### 1.4. Google AdManager初期設定
1. 広告表示に使用する機能を選択します。  
	ファイル`Info.plist`に以下の内容を記載します。  
	指定しない場合、起動時アプリがクラッシュします。  

	| 機能 | Key | Type | Value |
	| :-- | :-- | :-- | :-- |
	| Google AdManagerを使用する場合 | GADApplicationIdentifier | String | AdManagerのアプリID<br>(AdManager管理画面から取得する) |

### 2. アプリの処理実装
#### 2.1. 初期化処理
アプリケーション起動後処理(AppDelegate)にFirebaseの初期化処理を追加します。

・objecticec

```objecticec
@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    return YES;
}
@end
```
・swift

```swift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
}
```

#### 2.2. Firebase処理
詳細なFirebaseのRemoteConfig機能については以下のURLを参考してください。

参考サイト：[Firebase Remote ConfigをiOSで使用する](https://firebase.google.com/docs/remote-config/use-config-ios?hl=ja)

##### 2.2.1 初期処理
1. Firebase機能を使用するため、import処理を追加します。

	・objectivec
	
	```objectivec
	@import Firebase;
	```
	・swift
	
	```swift
	import Firebase
	```

2. メソッド`viewDidLoad`で、以下の初期処理を行います。
	- RemoteConfigオブジェクトの取得。  
	- RemoteConfig機能で情報が取得できなかった場合のdefault値指定(`remoteConfig.setDefaults`処理で、plistファイル(`1.2.`で作成)を指定します)  

	・objectivec
	
	```objectivec
	@interface ViewController ()
	@property(nonatomic, weak) FIRRemoteConfig *remoteConfig;
	@end
	
	@implementation ViewController
	
	// For Firebase.
	static NSString* const FIREBASE_DEFAULT_REMOTE_CONFIG = @"DefaultRemoteConfig";
	static double const FIREBASE_FETCH_TIME_INTERVAL_SECONDS = 720;

	- (void)viewDidLoad {
	    [super viewDidLoad];
	    // Do any additional setup after loading the view.
	    _remoteConfig = [FIRRemoteConfig remoteConfig];
	    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] init];
	    remoteConfigSettings.minimumFetchInterval = FIREBASE_FETCH_TIME_INTERVAL_SECONDS;
	    _remoteConfig.configSettings = remoteConfigSettings;
	    [_remoteConfig setDefaultsFromPlistFileName:FIREBASE_DEFAULT_REMOTE_CONFIG];    
	}
	```
	・swift

	```swift
	// For Firebase.
	let FIREBASE_DEFAULT_REMOTE_CONFIG: String = "DefaultRemoteConfig"
	let FIREBASE_FETCH_TIME_INTERVAL_SECONDS: Double = 720
	
	var remoteConfig: RemoteConfig! = nil

	override func viewDidLoad() {
	    self.remoteConfig = RemoteConfig.remoteConfig()
	    self.remoteConfig.setDefaults(fromPlist: FIREBASE_DEFAULT_REMOTE_CONFIG)
	}
	```

##### 2.2.2 広告枠情報取得処理
1. `remoteConfig.fetch`処理でFirebaseへ広告枠情報のフェッチ要求を行います。  
	初期処理でdefault値登録を行った場合は、取得に失敗した場合でも登録したdefault値が返却されるので、エラーチェックは特に必要ありません。

	・objectivec

	```objectivec
	static NSString* const FIREBASE_KEY_CONFIG = @"GNWrapperConfig_iOS";
	
	[_remoteConfig fetchWithCompletionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
	    if (status == FIRRemoteConfigFetchStatusSuccess) {
	        [self.remoteConfig activateWithCompletion:^(BOOL changed, NSError * _Nullable error) {
	            NSString *data = self.remoteConfig[FIREBASE_KEY_CONFIG].stringValue;
	        }];
	    } else {
	        NSString *data = self.remoteConfig[FIREBASE_KEY_CONFIG].stringValue;
	    }
	}];
	```
	・swift
	
	```swift
	let FIREBASE_KEY_CONFIG: String = "GNWrapperConfig_iOS"
	
	remoteConfig.fetch(withExpirationDuration: TimeInterval(FIREBASE_FETCH_TIME_INTERVAL_SECONDS)) { (status, error) -> Void in
	    if (status == .success) {
	        self.remoteConfig.activate() { (changed, error) in
	            let data = self.remoteConfig[self.FIREBASE_KEY_CONFIG].stringValue
	        }
	    } else {
	        let data = self.remoteConfig[self.FIREBASE_KEY_CONFIG].stringValue
	    }
	}
	```

#### 2.3. GNWrapperAdSDK処理
##### 2.3.1 初期処理
1. GNWrapperAdSDK機能を使用するため、import処理を追加します。

	・objectivec
	
	```objectivec
	#import <GNWrapperAdSdk/GNWrapperAdSDK.h>
	```
	・swift
	ブリッジングヘッダーを作成し、以下を追加します。
	
	```swift
	#import <GNWrapperAdSdk/GNWrapperAdSDK.h>
	```

2. メソッド`viewDidLoad`で、以下の初期処理を行います。
	- GNWrapperAdBannerオブジェクトの生成・初期化とaddView処理。  

	・objectivec

	```objectivec
	// Ad Size.
	#define ADMANAGER_AD_SIZE kGADAdSizeBanner

	@interface ViewController () <GNWrapperAdDelegate>
	@property(nonatomic, retain) GNWrapperAdBanner *gnWrapperAd;
	@property(nonatomic, retain) GNCustomTargetingParams *targetParams;
	@end
	
	@implementation ViewController

	- (void)viewDidLoad {
	    [GNWrapperAdSDK setLogPriority:GNLogPriorityInfo];
	    _gnWrapperAdBanner = [[GNWrapperAdBanner alloc] init];
	    [_gnWrapperAd setHidden:true];
	    [self.view addSubview:_gnWrapperAd];
	    _gnWrapperAd.frame = CGRectMake(0, 0, ADMANAGER_AD_SIZE.size.width, ADMANAGER_AD_SIZE.size.height);
	    _gnWrapperAd.center = CGPointMake(self.view.center.x, self.view.center.y);
	}

	@end
	```
	・swift

	```swift
	let ADMANAGER_AD_SIZE: GADAdSize = kGADAdSizeBanner

	var gnWrapperAd: GNWrapperAdBanner! = nil
	var targetParams: GNCustomTargetingParams! = nil

	override func viewDidLoad() {
	    GNWrapperAdSDK.setLogPriority(GNLogPriorityInfo)	    self.gnWrapperAd = GNWrapperAdBanner.init()
	    self.gnWrapperAd.isHidden = true
	    self.view.addSubview(self.gnWrapperAd)
	    self.gnWrapperAd.frame = CGRect(x: 0, y: 0, width: ADMANAGER_AD_SIZE.size.width, height: ADMANAGER_AD_SIZE.size.height)
	    self.gnWrapperAd.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
	}
	```

##### 2.3.2 ロード処理
1. RemoteConfigのfetch処理完了時に、以下の処理を行います。

	・objectivec

	```objectivec
	NSString *data = self.remoteConfig[FIREBASE_KEY_CONFIG].stringValue;
	
	[self.gnWrapperAd initWithLoad:data delegate:self viewController:self];
	```
	・swift

	```swift
	let data = self.remoteConfig[self.FIREBASE_KEY_CONFIG].stringValue
	
	self.gnWrapperAd.initWithLoad(data, delegate: self, viewController: self)
	```

2. Delegate処理を追加します。  

	・objectivec

	```objectivec
	// GNWrapperAdBannerDelegate
	
	- (void)onComplete:(GNWrapperAdBanner*)view params:(GNCustomTargetingParams *)params {
	    _targetParams = params;
	}
	
	- (void)onError:(GNWrapperAdBanner*)view error:(NSError *)error{
	    NSLog(@"ViewController: onError = %@", error.localizedDescription);
	}
	```
	・swift

	```swift
	// GNWrapperAdBannerDelegate
	extension ViewController: GNWrapperAdBannerDelegate {
	
	    func onComplete(_ view:GNWrapperAdBanner, params: GNCustomTargetingParams) {
	        self.targetParams = params
	    }
	
	    func onError(_ view:GNWrapperAdBanner) {
	        print("ViewController: onError")
	    }
	
	}
	```

#### 2.4. 広告表示処理(AdManager)
詳細なAdManager機能の実装方法については、以下のURLを参考してください。

参考サイト：

- [初期処理](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start)
- [バナー広告](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/quick-start)
- [CustomTargeting](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/targeting#custom_targeting)
- [GoogleMobileAdsSDK(version 8.0.0)について](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/migration)

##### 2.4.1 初期処理
1. AdManager機能を使用するため、import処理を追加します。

	・objectivec
	
	```objectivec
	@import GoogleMobileAds;
	```
	・swift
	
	```swift
	import GoogleMobileAds
	```

2. メソッド`viewDidLoad`で、以下の初期処理を行います。
	- GAMBannerViewオブジェクトの生成・初期化とaddView処理。  

	・objectivec

	```objectivec
	@interface ViewController () <GADBannerViewDelegate, GADAppEventDelegate, GNWrapperAdDelegate>
	@property(nonatomic, strong) GAMBannerView *bannerView;
	@end
	
	@implementation ViewController
	
	- (void)viewDidLoad {
	    _bannerView = [[GAMBannerView alloc] initWithAdSize:ADMANAGER_AD_SIZE];
	    _bannerView.delegate = self;
	    _bannerView.appEventDelegate = self;
	    _bannerView.rootViewController = self;
	    [self.view addSubview:_bannerView];
	    _bannerView.center = CGPointMake(self.view.center.x, self.view.center.y);
	}
	
	@end
	```
	・swift

	```swift
	var bannerView: DFPBannerView! = nil
	
	override func viewDidLoad() {
	    self.bannerView = GAMBannerView.init(adSize: ADMANAGER_AD_SIZE)
	    self.bannerView.delegate = self
	    self.bannerView.appEventDelegate = self
	    self.bannerView.rootViewController = self
	    self.view.addSubview(self.bannerView)
	    self.bannerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
	}
	```

3. Delegate処理を追加と、GNWrapperAdSDKへ現在表示している広告Viewの設定を行います。  
	- GADBannerViewDelegate。

	・objectivec
	
	```objectivec
	// GADBannerViewDelegate
	
	- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
	    [_gnWrapperAd requestRefresh:_bannerView];
	}

	- (void)bannerView:(nonnull GADBannerView *)bannerView
        didFailToReceiveAdWithError:(nonnull NSError *)error {
	    NSLog(@"ViewController: didFailToReceiveAdWithError: %@", [error localizedDescription]);
	}
	```
	・swift
	
	```swift
	extension ViewController: GADBannerViewDelegate {
	
	    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
	        self.gnWrapperAd.requestRefresh(self.bannerView)
	    }
	
	    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
	        print("ViewController: didFailToReceiveAdWithError: \(error.localizedDescription)")
	    }
	    
	}
	```

	- GADAppEventDelegate。

	・objectivec
	
	```objectivec
	/// GADAppEventDelegate.
	
	- (void)adView:(nonnull GADBannerView *)banner didReceiveAppEvent:(nonnull NSString *)name withInfo:(nullable NSString *)info {
	}
	```
	・swift
	
	```swift
	extension ViewController: GADAppEventDelegate {
	
	    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
	    }
	
	}
	```

##### 2.4.2 ロード処理
1. GNWrapperAdSDKのonComplete処理時に、以下の処理を行います。

	・objectivec

	```objectivec
	- (void)onComplete:(GNWrapperAd*)view params:(GNCustomTargetingParams *)params {
	    _targetParams = params;
	
	    [_gnWrapperAd setHidden:true];
	    [_bannerView setHidden:false];
	    _bannerView.adUnitID = _targetParams.unitId;
	
	    GAMRequest * request = [GAMRequest request];
	    request.customTargeting = _targetParams.targetParams;
	    [self.bannerView loadRequest:request];
	}
	```
	・swift
	
	```swift
	func onComplete(_ view:GNWrapperAd, params: GNCustomTargetingParams) {
	    self.targetParams = params
	
	    self.gnWrapperAd.isHidden = true
	    self.bannerView.isHidden = false
	    self.bannerView.adUnitID = self.targetParams.unitId
	
	    let request: GAMRequest = GAMRequest.init()
	    request.customTargeting = (self.targetParams.targetParams as! [String : String])
	    self.bannerView.load(request)
	}
	```

2. 広告枠情報に"Prebid"情報がある場合、AdManagerのロード完了時に、以下の処理を追加します。

	・objectivec

	```objectivec
	- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
	    [_gnWrapperAd requestRefresh:_bannerView];
	    if ([@"Prebid" isEqualToString:[_gnWrapperAd getAfterLoadedGAMBanner]]) {
	        [AdViewUtils findPrebidCreativeSize:_bannerView
	                                    success:^(CGSize size) {
	                                        [_bannerView resize:GADAdSizeFromCGSize(size)];
	                                    } failure:^(NSError * _Nonnull error) {
	                                        [GNLog logWithPriority:GNLogPriorityError message:[NSString stringWithFormat:@"ViewController: adViewDidReceiveAd error = %@", [error localizedDescription]]];
	                                    }];
	    }
	}
	```
	・swift
	
	```swift
	func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
		self.gnWrapperAd.requestRefresh(self.bannerView)
	    if ("Prebid" == self.gnWrapperAd.getAfterLoadedGAMBanner()) {
	        AdViewUtils.findPrebidCreativeSize(self.bannerView,
	            success: { (size) in
	                self.bannerView.resize(GADAdSizeFromCGSize(size))
	            },
	            failure: { (error) in
	                print("ViewController: adViewDidReceiveAd error = \(error.localizedDescription)")
	            }
	        )
	    }
	}
	```

3. 広告枠情報に"Pubmatic"情報がある場合、AdManagerのAppEvent時に、以下の処理を追加します。

	・objectivec

	```objectivec
	- (void)adView:(nonnull GADBannerView *)banner didReceiveAppEvent:(nonnull NSString *)name withInfo:(nullable NSString *)info {
	    if ([@"pubmaticdm" isEqualToString:name]) {
	        if ([_gnWrapperAd isNecessaryShow]) {
	            [_gnWrapperAd setHidden:false];
	            [_bannerView setHidden:true];
	
	            [_gnWrapperAd show];
	            [_gnWrapperAd requestRefresh:_gnWrapperAd];
	        }
	    }
	}
	```
	・swift
	
	```swift
	func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
	    if ("pubmaticdm" == name) {
	        if (self.gnWrapperAd.isNecessaryShow()) {
	            self.gnWrapperAd.isHidden = false
	            self.bannerView.isHidden = true
	
	            self.gnWrapperAd.show()
	            self.gnWrapperAd.requestRefresh(self.gnWrapperAd)
	        }
	    }
	}
	```

## 備考
- 一連の実装コードのついては、サンプルアプリを参考にしてください。
- iOS14以降、IDFAを使用するにはユーザーの明示的な許可が必要となります。(本対応はAppleの発表では2021年のはじめ頃より対応となります。対応方法は[こちら](https://developers.google.com/ad-manager/mobile-ads-sdk/ios/ios14)を参照ください。
