//
//  SASMopubRewardedVideoCustomEvent.m
//  MoPubSampleApp
//
//  Created by Thomas Geley on 22/12/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "SASMopubRewardedVideoCustomEvent.h"

#import "MPLogging.h"
#import "MPInstanceProvider.h"
#import "MPRewardedVideoReward.h"

#import "SASMopubCustomEventConstants.h"
#import "SASInterstitialView.h"
#import "SASAdViewDelegate.h"
#import "SASReward.h"

@interface MPInstanceProvider (SmartAdServerRewarded)
- (SASInterstitialView *)createSASInterstitialViewWithFrame:(CGRect)frame;
@end

@implementation MPInstanceProvider (SmartAdServerRewarded)
- (SASInterstitialView *)createSASInterstitialViewWithFrame:(CGRect)frame {
    return [[SASInterstitialView alloc] initWithFrame:frame];
}
@end

@interface SASMopubRewardedVideoCustomEvent () <SASAdViewDelegate>
@property (nonatomic, strong) SASInterstitialView *interstitial;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, assign) BOOL clickTracked;
@property (nonatomic, assign) BOOL impressionTracked;
@end

@implementation SASMopubRewardedVideoCustomEvent

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyAdView];
}


- (void)destroyAdView {
    if (self.interstitial) {
        [self.interstitial removeFromSuperview];
        self.interstitial.delegate = nil;
        self.interstitial.modalParentViewController = nil;
    }
    _adLoaded = NO;
    _impressionTracked = NO;
    _clickTracked = NO;
}

#pragma mark - Request Ad

- (BOOL)hasAdAvailable {
    return _adLoaded;
}


- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    
    //Reset banner view
    [self destroyAdView];
    
    //Set SiteID and baseURL
    [SASAdView setSiteID:[[info objectForKey:@"siteid"] integerValue] baseURL:kSASMopubBaseURLString];
    
    //Location is not enabled for rewarded videos...
    
    //Create AdView
    CGRect frame = [[self rootView] bounds];
    self.interstitial = [[MPInstanceProvider sharedProvider] createSASInterstitialViewWithFrame:frame];
    self.interstitial.delegate = self;
    
    //Load ad from infos dictionary
    [self.interstitial loadFormatId:[[info objectForKey:@"formatid"] integerValue] pageId:[info objectForKey:@"pageid"] master:YES target:[info objectForKey:@"target"]];    
}


- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    self.interstitial.modalParentViewController = viewController;
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [[self rootView] addSubview:self.interstitial];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}


- (UIView *)rootView {
    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
}


- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

#pragma mark - SASAdViewDelegate

- (void)adViewDidLoad:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial Did Load");
    _adLoaded = YES;
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart AdServer Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}


- (void)adViewDidDisappear:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial Did Disappear");
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}


- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit {
    MPLogInfo(@"Smart AdServer Interstitial will leave the application");
    [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
}


- (void)adViewWillPresentModalView:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial will present modal");
    [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
}


- (void)adView:(SASAdView *)adView didCollectReward:(nonnull SASReward *)reward {
     MPLogInfo(@"Smart AdServer Interstitial didCollect Reward");
    MPRewardedVideoReward *mopubConvertedReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:reward.currency amount:reward.amount];
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:mopubConvertedReward];
}


@end
