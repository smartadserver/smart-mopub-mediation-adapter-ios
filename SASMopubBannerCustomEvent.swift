//
//  SASMopubBannerCustomEvent.swift
//  SASMopubBannerCustomEvent
//
//  Created by Loïc GIRON DIT METAZ on 01/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

@objc(SASMopubBannerCustomEvent)
class SASMopubBannerCustomEvent: MPInlineAdAdapter {
    
    private var bannerView: SASBannerView? = nil
    
    override func requestAd(with size: CGSize, adapterInfo info: [AnyHashable : Any], adMarkup: String?) {
        do {
            // Extracting placement from custom event info
            let adPlacement = try SASMopubUtils.adPlacement(customEventInfo: info)
            
            // Creating a banner instance
            let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            bannerView = SASBannerView(frame: rect)
            bannerView?.delegate = self
            bannerView?.modalParentViewController = delegate?.inlineAdAdapterViewController(forPresentingModalView: self)
            bannerView?.autoresizingMask = [.flexibleWidth]
            
            // Loading ad from ad placement
            bannerView?.load(with: adPlacement)
        } catch {
            // Failing if custom info are invalid
            delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
        }
    }
    
    override func enableAutomaticImpressionAndClickTracking() -> Bool {
        return true
    }
    
}

extension SASMopubBannerCustomEvent: SASBannerViewDelegate {
    
    func bannerViewDidLoad(_ bannerView: SASBannerView) {
        if let bannerView = self.bannerView {
            delegate?.inlineAdAdapter(self, didLoadAdWithAdView: bannerView)
        }
    }
    
    func bannerView(_ bannerView: SASBannerView, didFailToLoadWithError error: Error) {
        delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    func bannerViewWillPresentModalView(_ bannerView: SASBannerView) {
        delegate?.inlineAdAdapterWillBeginUserAction(self)
    }
    
    func bannerViewWillDismissModalView(_ bannerView: SASBannerView) {
        delegate?.inlineAdAdapterDidEndUserAction(self)
    }
    
}
