//
//  SASMopubInterstitialCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 21/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubInterstitialCustomEvent.h"
#import "SASMopubUtils.h"
#import "MPAdAdapterError.h"
#import "MPLogging.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubInterstitialCustomEvent () <SASInterstitialManagerDelegate>

@property (nonatomic, strong, nullable) SASInterstitialManager *interstitialManager;

@end

@implementation SASMopubInterstitialCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;
@dynamic isRewardExpected;


#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyInterstitialManager];
}

- (void)destroyInterstitialManager {
    self.interstitialManager.delegate = nil;
    self.interstitialManager = nil;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.interstitialManager.adStatus == SASAdStatusReady;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup {

    // Reset interstitial manager
    [self destroyInterstitialManager];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Creating a new interstitial manager
    self.interstitialManager = [[SASInterstitialManager alloc] initWithPlacement:adPlacement delegate:self];
    
    // Loading ad from ad placement
    [self.interstitialManager load];
    
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.interstitialManager.adStatus == SASAdStatusReady) {
        [self.interstitialManager showFromViewController:viewController];
    } else {
        // We will send the error if the interstitial ad has already been presented or not ready.
        NSError *error = [NSError
                          errorWithDomain:MPAdAdapterErrorDomain
                          code:MPAdAdapterErrorCodeNoAdReady
                          userInfo:@{NSLocalizedDescriptionKey : @"Interstitial ad is not ready to be presented."}];
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    }
}

#pragma mark - Interstitial manager delegate

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    MPLogInfo(@"Smart Interstitial did load");
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Interstitial did appear");
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Interstitial did disappear");
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (BOOL)interstitialManager:(SASInterstitialManager *)manager shouldHandleURL:(NSURL *)URL {
    MPLogInfo(@"Smart Interstitial did receive tap event");
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
