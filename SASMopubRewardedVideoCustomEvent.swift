//
//  SASMopubRewardedVideoCustomEvent.swift
//  SASMopubRewardedVideoCustomEvent
//
//  Created by Loïc GIRON DIT METAZ on 01/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

@objc(SASMopubRewardedVideoCustomEvent)
class SASMopubRewardedVideoCustomEvent: MPFullscreenAdAdapter {
    
    private var rewardedVideoManager: SASRewardedVideoManager? = nil
    
    override func requestAd(withAdapterInfo info: [AnyHashable : Any], adMarkup: String?) {
        do {
            // Extracting placement from custom event info
            let adPlacement = try SASMopubUtils.adPlacement(customEventInfo: info)
            
            // Creating a new interstitial manager
            rewardedVideoManager = SASRewardedVideoManager(placement: adPlacement, delegate: self)
            
            // Loading ad from ad placement
            rewardedVideoManager?.load()
        } catch {
            // Failing if custom info are invalid
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
        }
    }
    
    override func presentAd(from viewController: UIViewController) {
        if rewardedVideoManager?.adStatus == .ready {
            rewardedVideoManager?.show(from: viewController)
        }
    }
    
    override var enableAutomaticImpressionAndClickTracking: Bool {
        return true
    }
    
}

extension SASMopubRewardedVideoCustomEvent: SASRewardedVideoManagerDelegate {
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didLoad ad: SASAd) {
        delegate?.fullscreenAdAdapterDidLoadAd(self)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didFailToLoadWithError error: Error) {
        delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didFailToShowWithError error: Error) {
        delegate?.fullscreenAdAdapter(self, didFailToShowAdWithError: error)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didAppearFrom viewController: UIViewController) {
        delegate?.fullscreenAdAdapterAdWillAppear(self)
        delegate?.fullscreenAdAdapterAdDidAppear(self)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didDisappearFrom viewController: UIViewController) {
        delegate?.fullscreenAdAdapterAdWillDisappear(self)
        delegate?.fullscreenAdAdapterAdDidDisappear(self)
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didCollect reward: SASReward) {
        if let reward = MPReward(currencyType: reward.currency, amount: reward.amount) {
            delegate?.fullscreenAdAdapter(self, willRewardUser: reward)
        }
    }
    
    func rewardedVideoManager(_ manager: SASRewardedVideoManager, didClickWith URL: URL) {
        delegate?.fullscreenAdAdapterDidReceiveTap(self)
    }
    
}
