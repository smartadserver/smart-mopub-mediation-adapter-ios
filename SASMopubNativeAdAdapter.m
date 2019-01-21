//
//  SASMopubNativeAdAdapter.m
//  SmartAdServer
//
//  Created by Thomas Geley on 26/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubNativeAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubNativeAdAdapter () <SASNativeAdDelegate, SASNativeAdMediaViewDelegate>

@property (nonatomic, strong, nullable) SASNativeAd *nativeAd;
@property (nonatomic, strong, nullable) SASAdChoicesView *adChoicesView;
@property (nonatomic, strong, nullable) SASNativeAdMediaView *mediaView;

@end

@implementation SASMopubNativeAdAdapter

@synthesize properties = _properties;

#pragma mark - Adapter LifeCycle

- (void)dealloc {
    // Remove AdChoicesView
    [self.adChoicesView removeFromSuperview];
    self.adChoicesView = nil;
    
    // Remove SASNativeAdMediaView
    [self.mediaView removeFromSuperview];
    self.mediaView.delegate = nil;
    self.mediaView = nil;
    
    // Reset Native Ad
    [self.nativeAd unregisterViews];
    self.nativeAd.delegate = nil;
    self.nativeAd = nil;
}

- (instancetype)initWithSASNativeAd:(SASNativeAd *)nativeAd {
    
    self = [super init];
    
    if (self) {
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        
        // Set Properties dictionary
        _properties = [self populatePropertiesFromNativeAd:nativeAd];
        
        // Create SASAdChoicesView
        self.adChoicesView = [[SASAdChoicesView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        // Create SASNativeAdMediaView if needed
        if ([self.nativeAd hasMedia]) {
            self.mediaView = [[SASNativeAdMediaView alloc] initWithFrame:CGRectZero];
        }
    }
    
    return self;
}

- (NSMutableDictionary *)populatePropertiesFromNativeAd:(SASNativeAd *)nativeAd {
    
    // Setup properties mapping with MPNativeAd
    NSMutableDictionary *adProperties = [NSMutableDictionary dictionary];
    
    // Rating
    if (nativeAd.rating) {
        [adProperties setObject:[NSNumber numberWithFloat:nativeAd.rating] forKey:kAdStarRatingKey];
    }
    
    // Title
    if (nativeAd.title) {
        [adProperties setObject:nativeAd.title forKey:kAdTitleKey];
    }
    
    // Body - Select either body or subtitle as Smart ad are often programmed with a subtitle instead of a body
    if (nativeAd.body || nativeAd.subtitle) {
        NSString *body = nativeAd.body ? nativeAd.body:nativeAd.subtitle;
        [adProperties setObject:body forKey:kAdTextKey];
    }
    
    // Add Subtitle if available, this is a not a default Mopub's key
    if (nativeAd.subtitle) {
        [adProperties setObject:nativeAd.subtitle forKey:@"subtitle"];
    }
    
    // CTA
    if (nativeAd.callToAction) {
        [adProperties setObject:nativeAd.callToAction forKey:kAdCTATextKey];
    }
    
    // Icon Image
    if (nativeAd.icon.URL) {
        [adProperties setObject:nativeAd.icon.URL.absoluteString forKey:kAdIconImageKey];
    }
    
    // Cover Image
    if (nativeAd.coverImage.URL) {
        [adProperties setObject:nativeAd.coverImage.URL.absoluteString forKey:kAdMainImageKey];
    }
    
    // Privacy Policy URL
    [adProperties setObject:@"http://smartadserver.com/company/privacy-policy/" forKey:kPrivacyIconTapDestinationURL];
    
    return adProperties;
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil;
}

- (BOOL)enableThirdPartyClickTracking {
    return YES;
}

- (void)willAttachToView:(UIView *)view {
    [self.nativeAd registerView:view modalParentViewController:[self.delegate viewControllerForPresentingModalView]];
    
    if (self.adChoicesView) {
        [self.adChoicesView registerNativeAd:self.nativeAd modalParentViewController:[self.delegate viewControllerForPresentingModalView]];
    }
    
    if (self.mediaView) {
        [self.mediaView registerNativeAd:self.nativeAd];
    }
    
    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        [self.delegate nativeAdWillLogImpression:self];
    }
}

- (UIView *)privacyInformationIconView {
    return self.adChoicesView;
}

- (UIView *)mainMediaView {
    return self.mediaView;
}

#pragma mark - SASNativeAdDelegate

- (void)nativeAdWillDismissModalView:(SASNativeAd *)nativeAd {
    // Careful about the chain of event, we are sending a DID dismiss whereas the received message is a WILL dismiss.
    [self.delegate nativeAdDidDismissModalForAdapter:self];
}

- (void)nativeAdWillPresentModalView:(SASNativeAd *)nativeAd {
    [self.delegate nativeAdWillPresentModalForAdapter:self];
}

- (BOOL)nativeAd:(SASNativeAd *)nativeAd shouldHandleClickURL:(NSURL *)URL {
    // NB: Smart Display SDK clicks can be counted multiple times, whereas MoPub will only count once. This might lead
    // to discrepencies between Mopub's and Smart's consoles.
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END
