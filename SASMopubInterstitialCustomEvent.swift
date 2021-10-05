//
//  SASMopubInterstitialCustomEvent.swift
//  SASMopubInterstitialCustomEvent
//
//  Created by Loïc GIRON DIT METAZ on 01/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

@objc(SASMopubInterstitialCustomEvent)
class SASMopubInterstitialCustomEvent: MPFullscreenAdAdapter {
    
    private var interstitialManager: SASInterstitialManager? = nil
    
    override func requestAd(withAdapterInfo info: [AnyHashable : Any], adMarkup: String?) {
        do {
            // Extracting placement from custom event info
            let adPlacement = try SASMopubUtils.adPlacement(customEventInfo: info)
            
            // Creating a new interstitial manager
            interstitialManager = SASInterstitialManager(placement: adPlacement, delegate: self)
            
            // Loading ad from ad placement
            interstitialManager?.load()
        } catch {
            // Failing if custom info are invalid
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
        }
    }
    
    override func presentAd(from viewController: UIViewController) {
        if interstitialManager?.adStatus == .ready {
            interstitialManager?.show(from: viewController)
        }
    }
    
    override var enableAutomaticImpressionAndClickTracking: Bool {
        return true
    }
    
}

extension SASMopubInterstitialCustomEvent: SASInterstitialManagerDelegate {
    
    func interstitialManager(_ manager: SASInterstitialManager, didLoad ad: SASAd) {
        delegate?.fullscreenAdAdapterDidLoadAd(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didFailToLoadWithError error: Error) {
        delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didAppearFrom viewController: UIViewController) {
        delegate?.fullscreenAdAdapterAdWillAppear(self)
        delegate?.fullscreenAdAdapterAdDidAppear(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didDisappearFrom viewController: UIViewController) {
        delegate?.fullscreenAdAdapterAdWillDisappear(self)
        delegate?.fullscreenAdAdapterAdDidDisappear(self)
    }
    
    func interstitialManager(_ manager: SASInterstitialManager, didClickWith URL: URL) {
        delegate?.fullscreenAdAdapterDidReceiveTap(self)
    }
    
}
