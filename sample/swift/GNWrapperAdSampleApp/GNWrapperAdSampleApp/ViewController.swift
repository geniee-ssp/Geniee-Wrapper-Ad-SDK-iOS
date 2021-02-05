//
//  ViewController.swift
//  GNWrapperAdSampleApp
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController {

    // For Firebase.
    let FIREBASE_DEFAULT_REMOTE_CONFIG: String = "DefaultRemoteConfig"
    let FIREBASE_FETCH_TIME_INTERVAL_SECONDS: Double = 720
    let FIREBASE_KEY_CONFIG: String = "GNWrapperConfig_iOS"
//    let FIREBASE_KEY_CONFIG: String = "GNWrapperConfig_iOS_Prebid"
//    let FIREBASE_KEY_CONFIG: String = "GNWrapperConfig_iOS_Pubmatic"
    // For GNWrapperSDK.
    let GNWRAPPERSDK_TEST_MODE: Bool = true
    // For AdManager.
    let ADMANAGER_AD_SIZE: GADAdSize = kGADAdSizeBanner
//    let ADMANAGER_AD_SIZE: GADAdSize = kGADAdSizeMediumRectangle
    let ADMANAGER_DEVELOPER_MODE: Bool = true

    var remoteConfig: RemoteConfig! = nil
    var gnWrapperAd: GNWrapperAdBanner! = nil
    var targetParams: GNCustomTargetingParams! = nil
    var bannerView: DFPBannerView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DispatchQueue.global().async {
            Util.checkIdfa()
            DispatchQueue.main.async {
                self.initFunction()
                self.requestTargetingData()
            }
        }
    }

    func initFunction() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.remoteConfig.setDefaults(fromPlist: FIREBASE_DEFAULT_REMOTE_CONFIG)

        GNWrapperAdSDK.setLogPriority(GNLogPriorityInfo)
        GNWrapperAdSDK.setTestMode(GNWRAPPERSDK_TEST_MODE)
        self.gnWrapperAd = GNWrapperAdBanner.init()
        self.gnWrapperAd.isHidden = true
        self.view.addSubview(self.gnWrapperAd)
        self.gnWrapperAd.frame = CGRect(x: 0, y: 0, width: ADMANAGER_AD_SIZE.size.width, height: ADMANAGER_AD_SIZE.size.height)
        self.gnWrapperAd.center = CGPoint(x: self.view.center.x, y: self.view.center.y)

        self.bannerView = DFPBannerView.init(adSize: ADMANAGER_AD_SIZE)
        self.bannerView.delegate = self
        self.bannerView.appEventDelegate = self
        self.bannerView.rootViewController = self
        self.view.addSubview(self.bannerView)
        self.bannerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
    }

    func requestTargetingData() {
        remoteConfig.fetch(withExpirationDuration: TimeInterval(FIREBASE_FETCH_TIME_INTERVAL_SECONDS)) { (status, error) -> Void in
            if (status == .success) {
                self.remoteConfig.activate() { (changed, error) in
                    let data = self.remoteConfig[self.FIREBASE_KEY_CONFIG].stringValue
                    print("ViewController: Get data = \(data!)")

                    self.gnWrapperAd.initWithLoad(data, delegate: self, viewController: self)
                }
            } else {
                let data = self.remoteConfig[self.FIREBASE_KEY_CONFIG].stringValue
                print("ViewController: Not fetched = \(data!)")

                self.gnWrapperAd.initWithLoad(data, delegate: self, viewController: self)
            }
        }
    }

    func requestAdManagerBanner() {
        self.gnWrapperAd.isHidden = true
        self.bannerView.isHidden = false
        self.bannerView.adUnitID = self.targetParams.unitId

        let request: DFPRequest = DFPRequest.init()
        request.customTargeting = (self.targetParams.targetParams as! [AnyHashable : Any])
        if (ADMANAGER_DEVELOPER_MODE) {
            request.testDevices = [Util.admobDeviceID()]
        }
        self.bannerView.load(request)
        print("ViewController: requestAdManagerBanner")
    }

    func reqestBanner() {
        if (self.gnWrapperAd.isNecessaryShow()) {
            self.gnWrapperAd.isHidden = false
            self.bannerView.isHidden = true

            self.gnWrapperAd.show()
            self.gnWrapperAd.requestRefresh(self.gnWrapperAd)
        }
    }

}
// GNWrapperAdBannerDelegate
extension ViewController: GNWrapperAdBannerDelegate {

    func onComplete(_ view:GNWrapperAdBanner, params: GNCustomTargetingParams) {
        self.targetParams = params
        print("ViewController: onComplete unitid = \(params.unitId!)")
        for key in params.targetParams.allKeys {
            print("ViewController: onComplete key = \(key) , val = \(params.targetParams.object(forKey: key)!)")
        }

        requestAdManagerBanner()
    }

    func onError(_ view:GNWrapperAdBanner) {
        print("ViewController: onError")
    }

}
extension ViewController: GADBannerViewDelegate {

    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("ViewController: adViewDidReceiveAd")
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

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("ViewController: didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
}
extension ViewController: GADAppEventDelegate {

    // Called when the banner receives an app event.
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        print("ViewController: didReceiveAppEvent: \(name)")

        if ("pubmaticdm" == name) {
            print("GNHBPubmaticAdapter delegate")
            reqestBanner()
        }
    }

}

