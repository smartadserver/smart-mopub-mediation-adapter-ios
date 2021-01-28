//
//  SASMopubBannerCustomEvent.m
//  SmartAdServer
//
//  Created by Thomas Geley on 21/12/2016.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

#import "MPLogging.h"
#import "MoPub.h"
#import "SASMopubBannerCustomEvent.h"
#import "SASMopubUtils.h"
#import <SASDisplayKit/SASDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASMopubBannerCustomEvent () <SASBannerViewDelegate>

@property (nonatomic, strong, nullable) SASBannerView *bannerView;

@end

@implementation SASMopubBannerCustomEvent
@dynamic delegate;
@dynamic localExtras;

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self destroyAdView];
}

- (void)destroyAdView {
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

#pragma mark - MPInlineAdAdapter Override

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup {
    
    // Reset banner view
    [self destroyAdView];
    
    // Extracting placement from custom event info
    NSError *error = nil;
    SASAdPlacement *adPlacement = [SASMopubUtils adPlacementWithCustomEventInfo:info error:&error];
    
    if (adPlacement == nil) {
        // Failing if custom info are invalid
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    // Creating a banner instance
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    self.bannerView = [[SASBannerView alloc] initWithFrame:frame];
    self.bannerView.delegate = self;
    self.bannerView.modalParentViewController = [self.delegate inlineAdAdapterViewControllerForPresentingModalView:self];
    self.bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Loading ad from ad placement
    [self.bannerView loadWithPlacement:adPlacement];
    
}

#pragma mark - Banner delegate

- (void)bannerViewDidLoad:(SASBannerView *)bannerView {
    MPLogInfo(@"Smart Banner did load");
    [self.delegate inlineAdAdapter:self didLoadAdWithAdView:self.bannerView];
}

- (void)bannerView:(SASBannerView *)bannerView didFailToLoadWithError:(NSError *)error {
    MPLogInfo(@"Smart Banner failed to load with error: %@", error.localizedDescription);
    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)bannerViewWillPresentModalView:(SASBannerView *)bannerView {
    MPLogInfo(@"Smart Banner will present modal");
    [self.delegate inlineAdAdapterWillBeginUserAction:self];
}

- (void)bannerViewWillDismissModalView:(SASBannerView *)bannerView {
    MPLogInfo(@"Smart Banner did dismiss modal");
    [self.delegate inlineAdAdapterDidEndUserAction:self];
}

@end

NS_ASSUME_NONNULL_END
