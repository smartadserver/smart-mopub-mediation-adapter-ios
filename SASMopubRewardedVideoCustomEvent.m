//
//  SASMopubRewardedVideoCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 22/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "SASMopubRewardedVideoCustomEvent.h"
#import "MoPub.h"
#import "SASMopubUtils.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubRewardedVideoCustomEvent () <SASRewardedVideoManagerDelegate>

@property (nonatomic, strong, nullable) SASRewardedVideoManager *rewardedVideoManager;

@end

@implementation SASMopubRewardedVideoCustomEvent

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyRewardedVideoManager];
}

- (void)destroyRewardedVideoManager {
    self.rewardedVideoManager.delegate = nil;
    self.rewardedVideoManager = nil;
}

#pragma mark - Request Ad

- (BOOL)hasAdAvailable {
    return self.rewardedVideoManager.adStatus == SASAdStatusReady;
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    
    // Reset rewarded video manager
    [self destroyRewardedVideoManager];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    // Location is not enabled for rewarded videos…
    // It is therefore not forwarded to the Smart Display SDK
    
    // Creating a new rewarded video manager
    self.rewardedVideoManager = [[SASRewardedVideoManager alloc] initWithPlacement:adPlacement delegate:self];
    
    // Loading ad from ad placement
    [self.rewardedVideoManager load];
    
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if (self.rewardedVideoManager.adStatus == SASAdStatusReady) {
        [self.rewardedVideoManager showFromViewController:viewController];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

#pragma mark - Rewarded video manager

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadAd:(SASAd *)ad {
    MPLogInfo(@"Smart Rewarded Video did load");
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart Rewarded Video did fail to load with error: %@", error.localizedDescription);
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToShowWithError:(NSError *)error {
    MPLogInfo(@"Smart Rewarded Video did fail to show with error: %@", error.localizedDescription);
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Rewarded Video did appear");
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    MPLogInfo(@"Smart Rewarded Video did disappear");
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didCollectReward:(SASReward *)reward {
    MPLogInfo(@"Smart Rewarded Video did collect reward");
    MPRewardedVideoReward *mopubConvertedReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:reward.currency amount:reward.amount];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:mopubConvertedReward];
}

- (BOOL)rewardedVideoManager:(SASRewardedVideoManager *)manager shouldHandleURL:(NSURL *)URL {
    MPLogInfo(@"Smart Rewarded Video did receive tap");
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
