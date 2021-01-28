//
//  SASMopubRewardedVideoCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 22/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubRewardedVideoCustomEvent.h"
#import "MPRewardedVideoError.h"
#import "MPReward.h"
#import "MPLogging.h"
#import "SASMopubUtils.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubRewardedVideoCustomEvent () <SASRewardedVideoManagerDelegate>

@property (nonatomic, strong, nullable) SASRewardedVideoManager *rewardedVideoManager;

@end

@implementation SASMopubRewardedVideoCustomEvent
@dynamic delegate;
@dynamic localExtras;
@dynamic hasAdAvailable;
@dynamic isRewardExpected;

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyRewardedVideoManager];
}

- (void)destroyRewardedVideoManager {
    self.rewardedVideoManager.delegate = nil;
    self.rewardedVideoManager = nil;
}

#pragma mark - MPFullscreenAdAdapter Override

- (BOOL)isRewardExpected {
    return YES;
}

- (BOOL)hasAdAvailable {
    return self.rewardedVideoManager.adStatus == SASAdStatusReady;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup {

    // Reset rewarded video manager
    [self destroyRewardedVideoManager];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Creating a new rewarded video manager
    self.rewardedVideoManager = [[SASRewardedVideoManager alloc] initWithPlacement:adPlacement delegate:self];
    
    // Loading ad from ad placement
    [self.rewardedVideoManager load];
    
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.rewardedVideoManager.adStatus == SASAdStatusReady) {
        [self.rewardedVideoManager showFromViewController:viewController];
    }
}

- (void)handleDidPlayAd {
    if (self.rewardedVideoManager.adStatus == SASAdStatusExpired) {
        [self.delegate fullscreenAdAdapterDidExpire:self];
    }
}

#pragma mark - Rewarded video manager

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadAd:(SASAd *)ad {
    MPLogInfo(@"Smart Rewarded Video did load");
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart Rewarded Video did fail to load with error: %@", error.localizedDescription);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToShowWithError:(NSError *)error {
    MPLogInfo(@"Smart Rewarded Video did fail to show with error: %@", error.localizedDescription);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Rewarded Video did appear");
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Rewarded Video did disappear");
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didCollectReward:(SASReward *)reward {
    MPLogInfo(@"Smart Rewarded Video did collect reward");
    MPReward *moPubReward = [[MPReward alloc] initWithCurrencyType:reward.currency amount:reward.amount];
    [self.delegate fullscreenAdAdapter:self willRewardUser:moPubReward];

}

- (BOOL)rewardedVideoManager:(SASRewardedVideoManager *)manager shouldHandleURL:(NSURL *)URL {
    MPLogInfo(@"Smart Rewarded Video did receive tap");
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
