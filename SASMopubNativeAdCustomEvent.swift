//
//  SASMopubNativeAdCustomEvent.swift
//  SASMopubNativeAdCustomEvent
//
//  Created by Loïc GIRON DIT METAZ on 02/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

@objc(SASMopubNativeAdCustomEvent)
class SASMopubNativeAdCustomEvent: MPNativeCustomEvent {
    
    private var sasNativeAdManager: SASNativeAdManager? = nil
    
    override func requestAd(withCustomEventInfo info: [AnyHashable : Any]!, adMarkup: String!) {
        do {
            // Extracting placement from custom event info
            let adPlacement = try SASMopubUtils.adPlacement(customEventInfo: info)
            
            // Creating a native ad manager instance
            sasNativeAdManager = SASNativeAdManager(placement: adPlacement)
            
            // Requesting an ad for the current placement
            self.sasNativeAdManager?.requestAd({ [self] nativeAd, error in
                if let nativeAd = nativeAd {
                    sasNativeAdDidLoad(nativeAd: nativeAd)
                } else {
                    sasNativeAdDidFailToLoad(error: error)
                }
            })
        } catch {
            // Failing if custom info are invalid
            delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: error)
        }
    }
    
    private func sasNativeAdDidLoad(nativeAd: SASNativeAd) {
        // Adapter initialization
        let adAdapter = SASMopubNativeAdAdapter(nativeAd: nativeAd)
        
        // MoPub ad initialization
        let interfaceAd = MPNativeAd(adAdapter: adAdapter)
        
        // Precaching images if possible…
        var imageURLs = [URL]()
        if let url = nativeAd.icon?.url {
            imageURLs.append(url)
        }
        if let url = nativeAd.coverImage?.url {
            imageURLs.append(url)
        }
        
        super.precacheImages(withURLs: imageURLs) { [self] errors in
            if errors != nil {
                delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: MPNativeAdNSErrorForImageDownloadFailure())
            } else {
                delegate?.nativeCustomEvent(self, didLoad: interfaceAd)
            }
        }
    }
    
    private func sasNativeAdDidFailToLoad(error: Error?) {
        delegate?.nativeCustomEvent(self, didFailToLoadAdWithError: error)
    }
    
}
