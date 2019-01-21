//
//  SASMopubNativeAdCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 26/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubNativeAdCustomEvent.h"
#import "SASMopubNativeAdAdapter.h"
#import "SASMopubUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubNativeAdCustomEvent ()

@property (nonatomic, strong, nullable) SASNativeAdManager *sasNativeAdManager;

@end

@implementation SASMopubNativeAdCustomEvent

#pragma mark - Dealloc

- (void)dealloc {
    [self resetNativeAdManager];
}

- (void)resetNativeAdManager {
    self.sasNativeAdManager = nil;
}

#pragma mark - Custom Event Extension

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    
    // Reset native ad manager
    [self resetNativeAdManager];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
        
    // Creating a native ad manager instance
    self.sasNativeAdManager = [[SASNativeAdManager alloc] initWithPlacement:adPlacement];
    
    // Requesting an ad for the current placement
    [self.sasNativeAdManager requestAd:^(SASNativeAd * _Nullable ad, NSError * _Nullable error) {
        if (ad) {
            [self sasNativeAdDidLoad:ad];
        } else {
            [self sasNativeAdDidFailToLoadWithError:error];
        }
    }];

}

#pragma mark - Ad Loading Methods

- (void)sasNativeAdDidLoad:(SASNativeAd *)nativeAd {
    
    // Adapter initialization
    SASMopubNativeAdAdapter *adAdapter = [[SASMopubNativeAdAdapter alloc] initWithSASNativeAd:nativeAd];
    
    // MoPub ad initialization
    MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    // Precaching images if possible…
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    if (nativeAd.icon.URL) {
        [imageURLs addObject:nativeAd.icon.URL];
    }
    
    if (nativeAd.coverImage.URL) {
        [imageURLs addObject:nativeAd.coverImage.URL];
    }
    
    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogInfo(@"Error(s) when precaching SASNativeAd image(s) : %@", errors);
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
        }
    }];
    
}

- (void)sasNativeAdDidFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Error when loading SASNativeAd : %@", error);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

@end

NS_ASSUME_NONNULL_END
