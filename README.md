Smart AdServer - MoPub SDK Adapter for iOS
==============================================

Introduction
------------

The **_Smart Display SDK_** (7.0+) can be used with **_MoPub SDK_** through _Custom Event Classes_ provided in this repository.
Supported Ad Formats are _Banners_, _Fullscreen_, _Rewarded Video_ and _Native Ads_.


Setup
-----

1) Install the **_Smart Display SDK_** in your Xcode project. This can be done using [Cocoapods](https://cocoapods.org/) (by installing the ```Smart-Display-SDK``` pod).

2) Checkout this repository and copy the **Custom Event Classes** you need into your XCode Project.
  * _`SASMopubBannerCustomEvent`_ for banner ads.
  * _`SASMopubInterstitialCustomEvent`_ for interstitial ads.
  * _`SASMopubRewardedVideoCustomEvent`_ for rewarded videos.
  * _`SASMopubNativeAdAdapter`_ **and** _`SASMopubNativeAdCustomEvent`_ for native ads.
  * _`SASMopubUtils`_ in any cases.

3) Edit the _`SASMopubUtils`_ header and replace the **`SASMopubAdapterBaseURLString`** with your dedicated baseURL.

4) _(Optional)_ **If you plan to use Native Ads, don't forget to add _`SASMopubNativeAdCustomEvent`_ as a _supportedCustomEvent_ to your _`MPNativeAdRendererConfiguration`_ or its subclass.**
  ```
  MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
  config.supportedCustomEvents =  @[@"SASMopubNativeAdCustomEvent"];
  ```

5) On your MoPub's dashboard, create a new ***Custom Native Network*** under the _Networks_ tab, and fill your Ad Units with the relevant Custom Event Classes. _For example for a banner Ad Unit, set `SASMopubBannerCustomEvent` as the **Custom Event Class**_.

6) Fill the _**Custom Event Class Data**_ with the informations of your _Smart AdServer's_ placements. You must use a valid JSON String and the 4 parameters : **siteid**, **pageid**, **formatid** and **target** must exist in this string. If you want to leave a parameter empty (_target for instance_) feel free to do it, as long as **all keys exist**.
  ```
  {"siteid":"your-siteID","pageid":"your-pageID","formatid":"your-formatID","target":"your-target-or-empty"}
  ```

7) Make sure your new _Custom Native Network_ is activated for your chosen Ad Units and Segments.

8) That's it, you're all set, you should be able to display _Smart AdServer's_ ads through your _MoPub SDK_ integration.


Known limitations
-----------------

- **Clicks counting** : you may experience discrepancies between _MoPub_ and _Smart AdServer_ click statistics. This is due to the fact that _MoPub_ can only count one click per ad whereas _Smart AdServer_ is able to count multiple clicks on the same ad.


More infos
----------

You can find more informations about the _Smart Display SDK_ and the _MoPub SDK Custom Events_ in the official documentation: http://documentation.smartadserver.com/displaySDK/
