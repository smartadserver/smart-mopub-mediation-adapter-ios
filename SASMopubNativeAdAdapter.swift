//
//  SASMopubNativeAdAdapter.swift
//  SASMopubNativeAdAdapter
//
//  Created by Loïc GIRON DIT METAZ on 02/09/2021.
//

import Foundation
import SASDisplayKit
import MoPubSDK

@objc(SASMopubNativeAdAdapter)
class SASMopubNativeAdAdapter: NSObject {
    
    weak var delegate: MPNativeAdAdapterDelegate? = nil
    
    var properties: [AnyHashable : Any]!
    var defaultActionURL: URL! = nil
    
    private var nativeAd: SASNativeAd? = nil
    private var adChoicesView: SASAdChoicesView? = nil
    private var mediaView: SASNativeAdMediaView? = nil
    
    deinit {
        adChoicesView?.removeFromSuperview()
        
        mediaView?.removeFromSuperview()
        mediaView?.delegate = nil
        
        nativeAd?.unregisterViews()
        nativeAd?.delegate = nil
    }
    
    init(nativeAd: SASNativeAd) {
        super.init()
        
        self.nativeAd = nativeAd
        nativeAd.delegate = self
        
        // Set Properties dictionary
        properties = properties(from: nativeAd)
        
        // Create SASAdChoicesView
        adChoicesView = SASAdChoicesView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        
        // Create SASNativeAdMediaView if needed
        if nativeAd.hasMedia {
            mediaView = SASNativeAdMediaView(frame: .zero)
        }
    }
    
    private func properties(from nativeAd: SASNativeAd) -> [AnyHashable : Any] {
        var adProperties = [String : Any]()
        
        // Rating
        if nativeAd.rating != Float(SASRatingUndefined) {
            adProperties[kAdStarRatingKey] = NSNumber(floatLiteral: Double(nativeAd.rating))
        }
        
        // Title
        if let title = nativeAd.title {
            adProperties[kAdTitleKey] = title
        }
        
        // Body - Select either body or subtitle as Smart ad are often programmed with a subtitle instead of a body
        if nativeAd.body != nil || nativeAd.subtitle != nil {
            let body = nativeAd.body != nil ? nativeAd.body : nativeAd.subtitle
            adProperties[kAdTextKey] = body
        }
        
        // Add Subtitle if available, this is a not a default Mopub's key
        if let subtitle = nativeAd.subtitle {
            adProperties["subtitle"] = subtitle
        }
        
        // CTA
        if let callToAction = nativeAd.callToAction {
            adProperties[kAdCTATextKey] = callToAction
        }
        
        // Icon Image
        if let url = nativeAd.icon?.url {
            adProperties[kAdIconImageKey] = url.absoluteString
        }
        
        // Cover Image
        if let url = nativeAd.coverImage?.url {
            adProperties[kAdMainImageKey] = url.absoluteString
        }
        
        // Privacy Policy URL
        adProperties[kPrivacyIconTapDestinationURL] = "http://smartadserver.com/company/privacy-policy/"
        
        return adProperties
    }
    
    
}

extension SASMopubNativeAdAdapter: MPNativeAdAdapter {
    
    func enableThirdPartyClickTracking() -> Bool {
        return true
    }
    
    func willAttach(to view: UIView!) {
        if let nativeAd = nativeAd, let viewController = delegate?.viewControllerForPresentingModalView() {
            nativeAd.register(view, modalParentViewController: viewController)
            
            if adChoicesView != nil {
                adChoicesView?.register(nativeAd, modalParentViewController: viewController)
            }
            
            if mediaView != nil {
                mediaView?.registerNativeAd(nativeAd)
            }
            
            delegate?.nativeAdWillLogImpression?(self)
        }
    }
    
    func privacyInformationIconView() -> UIView! {
        return adChoicesView
    }
    
    func mainMediaView() -> UIView! {
        return mediaView
    }
    
}

extension SASMopubNativeAdAdapter: SASNativeAdDelegate, SASNativeAdMediaViewDelegate {
    
    func nativeAdWillPresentModalView(_ nativeAd: SASNativeAd) {
        delegate?.nativeAdWillPresentModal(for: self)
    }
    
    func nativeAdWillDismissModalView(_ nativeAd: SASNativeAd) {
        // Careful about the chain of event, we are sending a DID dismiss whereas the received message is a WILL dismiss.
        delegate?.nativeAdDidDismissModal(for: self)
    }
    
    func nativeAd(_ nativeAd: SASNativeAd, didClickWith URL: URL) {
        // NB: Smart Display SDK clicks can be counted multiple times, whereas MoPub will only count once. This might lead
        // to discrepencies between Mopub's and Smart's consoles.
        delegate?.nativeAdDidClick?(self)
    }
    
}
