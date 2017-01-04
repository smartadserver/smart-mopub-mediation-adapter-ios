//
//  SASMopubInterstitialCustomEvent.m
//
//  Created by Thomas Geley on 21/12/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "SASMopubInterstitialCustomEvent.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"

#import "SASMopubCustomEventConstants.h"
#import "SASInterstitialView.h"
#import "SASAdViewDelegate.h"

@interface MPInstanceProvider (SmartAdServerInterstitials)
- (SASInterstitialView *)createSASInterstitialViewWithFrame:(CGRect)frame;
@end

@implementation MPInstanceProvider (SmartAdServerInterstitials)
- (SASInterstitialView *)createSASInterstitialViewWithFrame:(CGRect)frame {
    return [[SASInterstitialView alloc] initWithFrame:frame];
}
@end

@interface SASMopubInterstitialCustomEvent () <SASAdViewDelegate>
@property (nonatomic, strong) SASInterstitialView *interstitial;
@property (nonatomic, assign) BOOL adLoaded;
@property (nonatomic, assign) BOOL clickTracked;
@property (nonatomic, assign) BOOL impressionTracked;
@end

@implementation SASMopubInterstitialCustomEvent

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

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info; {
    
    //Reset banner view
    [self destroyAdView];
    
    //Set SiteID and baseURL
    [SASAdView setSiteID:[[info objectForKey:@"siteid"] integerValue] baseURL:kSASMopubBaseURLString];
    
    //Set location if enabled
    CLLocation *location = self.delegate.location;
    if (location) {
        [SASAdView setLocation:location];
    }
    
    //Create AdView
    CGRect frame = [[self rootView] bounds];
    self.interstitial = [[MPInstanceProvider sharedProvider] createSASInterstitialViewWithFrame:frame];
    self.interstitial.delegate = self;
    
    //Load ad from infos dictionary
    [self.interstitial loadFormatId:[[info objectForKey:@"formatid"] integerValue] pageId:[info objectForKey:@"pageid"] master:YES target:[info objectForKey:@"target"]];    
}


- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    self.interstitial.modalParentViewController = rootViewController;
    [self.delegate interstitialCustomEventWillAppear:self];
    [[self rootView] addSubview:self.interstitial];
    [self.delegate interstitialCustomEventDidAppear:self];
}


- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}


- (UIView *)rootView {
    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
}

#pragma mark - SASAdViewDelegate

- (void)adViewDidLoad:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial Did Load");
    _adLoaded = YES;
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart AdServer Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}


- (void)adViewDidDisappear:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial Did Disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}


- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit {
    MPLogInfo(@"Smart AdServer Interstitial will leave the application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}


- (void)adViewWillPresentModalView:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Interstitial will present modal");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
