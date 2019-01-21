//
//  SASMopubBannerCustomEvent.m
//  Smart AdServer
//
//  Created by Thomas Geley on 21/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "MPLogging.h"

#import "SASMopubCustomEventConstants.h"
#import "SASBannerView.h"
#import "SASAdViewDelegate.h"
#import "SASMopubBannerCustomEvent.h"

@interface SASMopubBannerCustomEvent () <SASAdViewDelegate>
@property (nonatomic, strong) SASBannerView *bannerView;
@end

@implementation SASMopubBannerCustomEvent

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyAdView];
}


- (void)destroyAdView {
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView.delegate = nil;
        self.bannerView.modalParentViewController = nil;
    }
}

#pragma mark - Request Ad

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    
    //Reset banner view
    [self destroyAdView];
    
    //Set SiteID and baseURL
    [SASAdView setSiteID:[[info objectForKey:@"siteid"] integerValue] baseURL:kSASMopubBaseURLString];
    
    //Set location if enabled
    CLLocation *location = self.delegate.location;
    if (location) {
         [SASAdView setLocation:location];
    }
    
    //Create Banner
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    self.bannerView = [[SASBannerView alloc] initWithFrame:frame];
    self.bannerView.delegate = self;
    self.bannerView.modalParentViewController = [self.delegate viewControllerForPresentingModalView];
    self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //Load ad from infos dictionary
    [self.bannerView loadFormatId:[[info objectForKey:@"formatid"] integerValue] pageId:[info objectForKey:@"pageid"] master:YES target:[info objectForKey:@"target"]];
    
}

#pragma mark - SASAdViewDelegate

- (void)adViewDidLoad:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:self.bannerView];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart AdServer Banner failed to load with error: %@", error.localizedDescription);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}


- (void)adView:(SASAdView *)adView willPerformActionWithExit:(BOOL)willExit {
    MPLogInfo(@"Smart AdServer Banner will leave the application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


- (void)adViewWillPresentModalView:(SASAdView *)adView {
     MPLogInfo(@"Smart AdServer Banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];
}


- (void)adViewWillDismissModalView:(SASAdView *)adView {
    MPLogInfo(@"Smart AdServer Banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];
}


@end
