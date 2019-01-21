//
//  SASMopubInterstitialCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 21/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubInterstitialCustomEvent.h"
#import "MoPub.h"
#import "SASMopubUtils.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubInterstitialCustomEvent () <SASInterstitialManagerDelegate>

@property (nonatomic, strong, nullable) SASInterstitialManager *interstitialManager;

@end

@implementation SASMopubInterstitialCustomEvent

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyInterstitialManager];
}

- (void)destroyInterstitialManager {
    self.interstitialManager.delegate = nil;
    self.interstitialManager = nil;
}

#pragma mark - Request Ad

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    
    // Reset interstitial manager
    [self destroyInterstitialManager];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Setting location if enabled
    CLLocation *location = self.delegate.location;
    if (location) {
        [SASConfiguration sharedInstance].manualLocation = location.coordinate;
    }
    
    // Creating a new interstitial manager
    self.interstitialManager = [[SASInterstitialManager alloc] initWithPlacement:adPlacement delegate:self];
    
    // Loading ad from ad placement
    [self.interstitialManager load];
    
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if (self.interstitialManager.adStatus == SASAdStatusReady) {
        [self.interstitialManager showFromViewController:rootViewController];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

#pragma mark - Interstitial manager delegate

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    MPLogInfo(@"Smart Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitialManager];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Interstitial did appear");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Interstitial did disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (BOOL)interstitialManager:(SASInterstitialManager *)manager shouldHandleURL:(NSURL *)URL {
    MPLogInfo(@"Smart Interstitial did receive tap event");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
