//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

#import "AirFlurry.h"
#import "Flurry.h"

FREContext AirFlurryCtx = nil;

@interface AirFlurry ()
{
    UIWindow *_applicationWindow;
    NSString *_interstitialDisplayed;
    NSMutableDictionary *_cookies;
    NSMutableDictionary *_targetingKeywords;
    NSString *_adMobPublisherID;
    NSString *_greystripeApplicationID;
    NSString *_inMobiAppKey;
    NSString *_jumptapApplicationID;
    NSString *_millenialAppKey;
    NSString *_millenialInterstitialAppKey;
    NSString *_mobclixApplicationID;
}

@property (nonatomic, readonly) UIView *rootView;
@property (nonatomic, readonly) UIView *bannerContainer;
@property (nonatomic, readonly) NSMutableDictionary *spacesStatus;

- (void)onWindowDidBecomeKey:(NSNotification *)notification;
- (BOOL)statusForSpace:(NSString *)space;
- (void)setStatus:(BOOL)status forSpace:(NSString *)space;

@end


@implementation AirFlurry

@synthesize bannerContainer = _bannerContainer;
@synthesize spacesStatus = _spacesStatus;

#pragma mark - Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    [_applicationWindow release];
    [_bannerContainer release];
    [_spacesStatus release];
    [_interstitialDisplayed release];
    [_cookies release];
    [_targetingKeywords release];
    [_adMobPublisherID release];
    [_greystripeApplicationID release];
    [_inMobiAppKey release];
    [_jumptapApplicationID release];
    [_millenialAppKey release];
    [_millenialInterstitialAppKey release];
    [_mobclixApplicationID release];
    [super dealloc];
}


#pragma mark - Singleton

static id sharedInstance = nil;

+ (AirFlurry *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}


#pragma mark - Analytics
- (void)startSession:(NSString *)apiKey
{
    NSLog(@"Starting Flurry session");
    
    _applicationWindow = [[[UIApplication sharedApplication] keyWindow] retain];
    
    [Flurry setDebugLogEnabled:YES];
    [Flurry startSession:apiKey];

    [FlurryAds setAdDelegate:self];
    [FlurryAds initialize:_applicationWindow.rootViewController];
    
    // Set third-party networks credentials
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *credentials = [info objectForKey:@"AppSpotCredentials"];
    if (credentials)
    {
        _adMobPublisherID = [[credentials objectForKey:@"AdMobPublisherID"] retain];
        _greystripeApplicationID = [[credentials objectForKey:@"GreystripeApplicationID"] retain];
        _inMobiAppKey = [[credentials objectForKey:@"InMobiAppKey"] retain];
        _jumptapApplicationID = [[credentials objectForKey:@"JumptapApplicationID"] retain];
        _millenialAppKey = [[credentials objectForKey:@"MillenialAppKey"] retain];
        _millenialInterstitialAppKey = [[credentials objectForKey:@"MillenialInterstitialAppKey"] retain];
        _mobclixApplicationID = [[credentials objectForKey:@"MobclixApplicationID"] retain];
    }
    
    // Listen to key window notification (bugfix for interstitial that disappear)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowDidBecomeKey:) name:UIWindowDidBecomeKeyNotification object:nil];
}


#pragma mark - Ads

- (UIView *)rootView
{
    return [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
}

- (UIView *)bannerContainer
{
    if (!_bannerContainer)
    {
        CGRect bannerFrame = CGRectZero;
        
        CGFloat sw = [UIScreen mainScreen].bounds.size.width;
        CGFloat sh = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat smin = sw;
        
        if (sh < sw)
            smin = sh;

        CGFloat bannerWidth;
        CGFloat bannerHeight;

        if (smin <= 320) {
            bannerWidth = 320;
            bannerHeight = 50;
        } else if (smin <= 640) {
            bannerWidth = 640;
            bannerHeight = 100;
        } else if (smin <= 768) {
            bannerWidth = 728;
            bannerHeight = 90;
        } else {
            bannerWidth = 1456;
            bannerHeight = 180;
        }
        
        bannerFrame.size = CGSizeMake(bannerWidth, bannerHeight);
        
        _bannerContainer = [[UIView alloc] initWithFrame:bannerFrame];
        
    }
    
    return _bannerContainer;
}

- (NSMutableDictionary *)spacesStatus
{
    if (!_spacesStatus)
    {
        _spacesStatus = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return _spacesStatus;
}

- (BOOL)statusForSpace:(NSString *)space
{
    if (!space) return NO;
    
    NSNumber *numberStatus = [self.spacesStatus objectForKey:space];
    
    return numberStatus ? [numberStatus boolValue] : NO;
}

- (void)setStatus:(BOOL)status forSpace:(NSString *)space
{
    [self.spacesStatus setObject:[NSNumber numberWithBool:status] forKey:space];
}

- (void)displayAdForSpace:(NSString *)space size:(FlurryAdSize)size
{
    UIView *adView = (size == FULLSCREEN) ? self.rootView : self.bannerContainer;
    
    if (size == BANNER_BOTTOM || size == BANNER_TOP)
    {
        CGRect bannerFrame = adView.frame;
        bannerFrame.origin.y = (size == BANNER_BOTTOM) ? self.rootView.bounds.size.height - bannerFrame.size.height : 0;
        adView.frame = bannerFrame;
    }
    
    if (size == BANNER_BOTTOM) {
        self.bannerContainer.contentMode = UIViewContentModeBottom;
    } else if (size == BANNER_TOP) {
        self.bannerContainer.contentMode = UIViewContentModeTop;
    } else if (size == FULLSCREEN) {
        self.rootView.contentMode = UIViewContentModeScaleToFill;
    }
    
    [self setStatus:YES forSpace:space];
    if (size == FULLSCREEN) _interstitialDisplayed = [space retain];
    else [self.rootView addSubview:adView];
    
    [FlurryAds displayAdForSpace:space onView:adView];
}

- (void)fetchAdForSpace:(NSString *)space size:(FlurryAdSize)size
{
    UIView *adView = (size == FULLSCREEN) ? self.rootView : self.bannerContainer;
    
    [FlurryAds fetchAdForSpace:space frame:adView.frame size:size];
}

- (void)removeAdFromSpace:(NSString *)space
{
    [self setStatus:NO forSpace:space];
    
    if ([space isEqualToString:_interstitialDisplayed])
    {
        [_interstitialDisplayed release];
        _interstitialDisplayed = nil;
    }
    else
    {
        [self.bannerContainer removeFromSuperview];
    }
    
    [FlurryAds removeAdFromSpace:space];
}

- (void)addUserCookieWithValue:(NSString *)value forKey:(NSString *)key
{
    if (!_cookies)
    {
        _cookies = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    [_cookies setObject:value forKey:key];
    [FlurryAds setUserCookies:_cookies];
}

- (void)clearUserCookies
{
    if (_cookies)
    {
        [_cookies removeAllObjects];
        [FlurryAds setUserCookies:_cookies];
    }
}

- (void)addTargetingKeywordWithValue:(NSString *)value forKey:(NSString *)key
{
    if (!_targetingKeywords)
    {
        _targetingKeywords = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    [_targetingKeywords setObject:value forKey:key];
    [FlurryAds setKeywordsForTargeting:_targetingKeywords];
}

- (void)clearTargetingKeywords
{
    if (_targetingKeywords)
    {
        [_targetingKeywords removeAllObjects];
        [FlurryAds setKeywordsForTargeting:_targetingKeywords];
    }
}


#pragma mark - FlurryAdDelegate

- (void) spaceDidReceiveAd:(NSString*)adSpace
{
    NSLog(@"[Flurry] Space did receive ad : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_RECEIVE_AD", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void) spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError *)error
{
    NSLog(@"[Flurry] Space failed to receive ad : %@. Error : %@", adSpace, [error description]);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_FAIL_TO_RECEIVE_AD", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (BOOL)spaceShouldDisplay:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    return YES;
}

- (void)spaceDidFailToRender:(NSString *)adSpace error:(NSError *)error
{
    NSLog(@"[Flurry] Ad failed to render: %@. Error: %@", adSpace, [error localizedDescription]);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_FAIL_TO_RENDER", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceWillDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    NSLog(@"[Flurry] Space will dismiss : %@. ", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_WILL_DISMISS", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    NSLog(@"[Flurry] Closed ad: %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_DISMISS", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceWillLeaveApplication:(NSString *)adSpace
{
    NSLog(@"[Flurry] Exit application after clicking on ad: %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_WILL_LEAVE_APPLICATION", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceWillExpand:(NSString *)adSpace
{
    NSLog(@"[Flurry] Space will expand : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_WILL_EXPAND", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceWillCollapse:(NSString *)adSpace
{
    NSLog(@"[Flurry] Space will collapse : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_WILL_COLLAPSE", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceDidCollapse:(NSString *)adSpace
{
    NSLog(@"[Flurry] Space did collapse : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_COLLAPSE", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void) spaceDidReceiveClick:(NSString*)adSpace
{
    NSLog(@"[Flurry] Space did receive click : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_AD_CLICKED", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)videoDidFinish:(NSString *)adSpace
{
    NSLog(@"[Flurry] Video did finish for space : %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_VIDEO_COMPLETED", (const uint8_t *)[adSpace UTF8String]);
    }
}




#pragma mark - FlurryAdDelegate - 3rd-party networks

- (NSString *)appSpotAdMobPublisherID
{
    return _adMobPublisherID;
}

- (NSString *)appSpotGreystripeApplicationID
{
    return _greystripeApplicationID;
}

- (NSString *)appSpotInMobiAppKey
{
    return _inMobiAppKey;
}

- (NSString *)appSpotJumptapApplicationID
{
    return _jumptapApplicationID;
}

- (NSString *)appSpotMillennialAppKey
{
    return _millenialAppKey;
}

- (NSString *)appSpotMillennialInterstitalAppKey
{
    return _millenialInterstitialAppKey;
}

- (NSString *)appSpotMobclixApplicationID
{
    return _mobclixApplicationID;
}


#pragma mark - NSNotificationCenter

- (void)onWindowDidBecomeKey:(NSNotification *)notification
{
    UIWindow *window = (UIWindow *)notification.object;
    
    if (window == _applicationWindow)
    {
        [AirFlurry log:@"Application window became key"];
    }
    else
    {
        [AirFlurry log:@"Other window became key"];
    }
    
    if (_interstitialDisplayed != nil)
    {
        [AirFlurry log:[NSString stringWithFormat:@"Interstitial displayed: %@", _interstitialDisplayed]];
    }
    
    if (window == _applicationWindow && _interstitialDisplayed != nil)
    {
        [self spaceDidDismiss:_interstitialDisplayed interstitial:YES];
        [_interstitialDisplayed release];
        _interstitialDisplayed = nil;
    }
}


#pragma mark - Other

+ (void)log:(NSString *)message
{
    FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
}

@end


#pragma mark - C interface - Flurry setup

DEFINE_ANE_FUNCTION(startSession)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *apiKey = [NSString stringWithUTF8String:(char*)value];
        [[AirFlurry sharedInstance] startSession:apiKey];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(stopSession)
{
    // Doesn't do anything on iOS.
    return nil;
}


#pragma mark - C interface - Analytics

DEFINE_ANE_FUNCTION(setAppVersion)
{
    uint32_t stringLength = 0;
    
    const uint8_t *value = NULL;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *versionName = [NSString stringWithUTF8String:(char*)value];
        [Flurry setAppVersion:versionName];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(logEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) != FRE_OK)
    {
        return nil;
    }
    NSString *eventName = [NSString stringWithUTF8String:(char*)value];
    
    NSMutableDictionary *params;
    if (argc > 1 && argv[1] != NULL && argv[2] != NULL && argv[1] != nil && argv[2] != NULL)
    {
        FREObject arrKey = argv[1]; // array
        uint32_t arr_len = 0; // array length
        
        FREObject arrValue = argv[2]; // array
        
        if (arrKey != nil)
        {
            if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
            {
                arr_len = 0;
            }
            
            params = [[NSMutableDictionary alloc] init];
            
            for (int32_t i = arr_len-1; i >= 0; i--)
            {
                // get an element at index
                FREObject key;
                if (FREGetArrayElementAt(arrKey, i, &key) != FRE_OK)
                {
                    continue;
                }
                
                FREObject value;
                if (FREGetArrayElementAt(arrValue, i, &value) != FRE_OK)
                {
                    continue;
                }
                
                // convert it to NSString
                uint32_t stringLength;
                const uint8_t *keyString;
                if (FREGetObjectAsUTF8(key, &stringLength, &keyString) != FRE_OK)
                {
                    continue;
                }
                
                const uint8_t *valueString;
                if (FREGetObjectAsUTF8(value, &stringLength, &valueString) != FRE_OK)
                {
                    continue;
                }
                
                [params setValue:[NSString stringWithUTF8String:(char*)valueString] forKey:[NSString stringWithUTF8String:(char*)keyString]];
            }
        }
    }
    
    if (params != nil && params.count > 0)
    {
        [Flurry logEvent:eventName withParameters:params];
    }
    else
    {
        [Flurry logEvent:eventName];
    }
 
    return nil;
}

DEFINE_ANE_FUNCTION(logError)
{
    uint32_t stringLength;
    
    const uint8_t *valueId;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &valueId) != FRE_OK)
    {
        return nil;
    }
    NSString *errorId = [NSString stringWithUTF8String:(char*)valueId];
    
    const uint8_t *valueMessage;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueMessage) != FRE_OK)
    {
        return nil;
    }
    NSString *message = [NSString stringWithUTF8String:(char*)valueMessage];
    
    [Flurry logError:errorId message:message error:nil];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserId)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *userId = [NSString stringWithUTF8String:(char*)value];
        [Flurry setUserID:userId];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserInfo)
{
    int32_t age = 0;
    if (FREGetObjectAsInt32(argv[0], &age) == FRE_OK)
    {
        [Flurry setAge:age];
    }

    uint32_t stringLength = 0;
    
    const uint8_t *value = NULL;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &value ) == FRE_OK)
    {
        NSString *gender = [NSString stringWithUTF8String:(char*)value];
        [Flurry setGender:gender];
    }
   
    return nil;
}

DEFINE_ANE_FUNCTION(setSendEventsOnPause)
{
    uint32_t onPause = NO;
    if (FREGetObjectAsBool(argv[0], &onPause) == FRE_OK)
    {
        [Flurry setSessionReportsOnPauseEnabled:onPause];
        [Flurry setSessionReportsOnCloseEnabled:!onPause];
    }
  
    return nil;
}

DEFINE_ANE_FUNCTION(startTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *eventName = [NSString stringWithUTF8String:(char*)value];
        [Flurry logEvent:eventName timed:YES];
    }

    return nil;
}

DEFINE_ANE_FUNCTION(stopTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *eventName = [NSString stringWithUTF8String:(char*)value];
        [Flurry endTimedEvent:eventName withParameters:nil];
    }

    return NULL;
}


#pragma mark - C interface - Ads

DEFINE_ANE_FUNCTION(fetchAd)
{
    NSLog(@"[Flurry] Calling fetchAd");
    
    NSString *space = nil;
    FlurryAdSize sizeValue;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    }
    
    NSLog(@"Ad space : %@", space);
    
    // Retrieve the ad size
    const uint8_t *sizeString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &sizeString) == FRE_OK)
    {
        NSString *size = [NSString stringWithUTF8String:(char*)sizeString];
        
        if ([size isEqualToString:@"BANNER_TOP"]) sizeValue = BANNER_TOP;
        else if ([size isEqualToString:@"BANNER_BOTTOM"]) sizeValue = BANNER_BOTTOM;
        else if ([size isEqualToString:@"FULLSCREEN"]) sizeValue = FULLSCREEN;
        else {
            NSLog(@"[Flurry] Error while fetching ad : wrong size : %@", size);
            return nil;
        }
    }
    else
    {
        NSLog(@"[Flurry] Error while fetching ad : couldn't retrieve ad size.");
        return nil;
    }
    
    NSLog(@"[Flurry] Ad size : %u", sizeValue);
    
    if (space != nil)
    {
        [[AirFlurry sharedInstance] fetchAdForSpace:space size:sizeValue];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(isAdReady)
{
    NSLog(@"[Flurry] Calling isAdReady");
    
    NSString *space = nil;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    }
    
    NSLog(@"Ad space : %@", space);
    
    FREObject result = nil;
    
    BOOL adReady = [FlurryAds adReadyForSpace:space];
    FRENewObjectFromBool(adReady, &result);
    return result;
}

DEFINE_ANE_FUNCTION(displayAd)
{
    NSString *space = nil;
    FlurryAdSize sizeValue;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) != FRE_OK) {
        NSLog(@"[Flurry] Could not retrieve space.");
        return nil;
    }
    
    space = [NSString stringWithUTF8String:(char*)spaceString];
    
    // Retrieve the ad size
    const uint8_t *sizeString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &sizeString) == FRE_OK)
    {
        NSString *size = [NSString stringWithUTF8String:(char*)sizeString];
        
        if ([size isEqualToString:@"BANNER_TOP"]) sizeValue = BANNER_TOP;
        else if ([size isEqualToString:@"BANNER_BOTTOM"]) sizeValue = BANNER_BOTTOM;
        else if ([size isEqualToString:@"FULLSCREEN"]) sizeValue = FULLSCREEN;
        else {
            NSLog(@"[Flurry] Error while displaying ad : wrong size : %@", size);
            return nil;
        }
    }
    else
    {
        NSLog(@"[Flurry] Error while displaying ad : couldn't retrieve ad size.");
        return nil;
    }

    [[AirFlurry sharedInstance] displayAdForSpace:space size:sizeValue];
    
    return nil;
}

DEFINE_ANE_FUNCTION(removeAd)
{
    NSString *space = nil;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    }
    
    if (space != nil)
    {
        // Remove the ad
        [[AirFlurry sharedInstance] removeAdFromSpace:space];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(addUserCookie)
{
    uint32_t stringLength;
    
    const uint8_t *keyString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &keyString) != FRE_OK)
    {
        return nil;
    }
    NSString *key = [NSString stringWithUTF8String:(char*)keyString];
    
    const uint8_t *valueString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueString) != FRE_OK)
    {
        return nil;
    }
    NSString *value = [NSString stringWithUTF8String:(char*)valueString];
    
    [[AirFlurry sharedInstance] addUserCookieWithValue:value forKey:key];
    
    return nil;
}

DEFINE_ANE_FUNCTION(clearUserCookies)
{
    [[AirFlurry sharedInstance] clearUserCookies];
    return nil;
}

DEFINE_ANE_FUNCTION(addTargetingKeyword)
{
    uint32_t stringLength;
    
    const uint8_t *keyString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &keyString) == FRE_OK)
    {
        return nil;
    }
    NSString *key = [NSString stringWithUTF8String:(char*)keyString];
    
    const uint8_t *valueString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueString) == FRE_OK)
    {
        return nil;
    }
    NSString *value = [NSString stringWithUTF8String:(char*)valueString];
    
    [[AirFlurry sharedInstance] addTargetingKeywordWithValue:value forKey:key];
    
    return nil;
}

DEFINE_ANE_FUNCTION(clearTargetingKeywords)
{
    [[AirFlurry sharedInstance] clearTargetingKeywords];
    return nil;
}

DEFINE_ANE_FUNCTION(enableTestAds)
{
    BOOL enable;
    
    if (FREGetObjectAsBool(argv[0], enable) == FRE_OK)
        [FlurryAds enableTestAds:enable];
    
    return nil;
}

DEFINE_ANE_FUNCTION(getDisplayedAdHeight)
{
    NSString *space = nil;
    uint32_t stringLength;
    
    FREObject result = nil;
    FRENewObjectFromInt32(0, &result);
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    } else {
        FRENewObjectFromInt32(0, &result);
        return result;
    }
    
    UIView* bannerView = [AirFlurry sharedInstance].bannerContainer;
    
    for(UIView* view in bannerView.subviews) {
        NSLog(@"Subview size : %f, %f", view.bounds.size.width, view.bounds.size.height);
        NSLog(@"Subview transforms : %f, %f, %f, %f", view.transform.a, view.transform.b, view.transform.c, view.transform.d);
        NSLog(@"Subview content scale factor : %f", view.contentScaleFactor);
    }
    
    NSLog(@"Transform : %f, %f, %f, %f", bannerView.transform.a, bannerView.transform.b, bannerView.transform.c, bannerView.transform.d);
    NSLog(@"Content scale factor : %f", bannerView.contentScaleFactor);
    
    FRENewObjectFromInt32([AirFlurry sharedInstance].bannerContainer.bounds.size.height, &result);
    return result;
}

#pragma mark - ANE setup

void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    static FRENamedFunction functionMap[] = {
        // Session
        MAP_FUNCTION(startSession, NULL),
        MAP_FUNCTION(stopSession, NULL),
        
        // Analytics
        MAP_FUNCTION(setAppVersion, NULL),
        MAP_FUNCTION(logEvent, NULL),
        MAP_FUNCTION(logError, NULL),
        MAP_FUNCTION(setUserId, NULL),
        MAP_FUNCTION(setUserInfo, NULL),
        MAP_FUNCTION(setSendEventsOnPause, NULL),
        MAP_FUNCTION(startTimedEvent, NULL),
        MAP_FUNCTION(stopTimedEvent, NULL),
        
        // Ads
        MAP_FUNCTION(fetchAd, NULL),
        MAP_FUNCTION(isAdReady, NULL),
        MAP_FUNCTION(displayAd, NULL),
        MAP_FUNCTION(removeAd, NULL),
        MAP_FUNCTION(addUserCookie, NULL),
        MAP_FUNCTION(clearUserCookies, NULL),
        MAP_FUNCTION(addTargetingKeyword, NULL),
        MAP_FUNCTION(clearTargetingKeywords, NULL),
        MAP_FUNCTION(enableTestAds, NULL),
        MAP_FUNCTION(getDisplayedAdHeight, NULL)
    };
    
	*numFunctionsToTest = sizeof( functionMap ) / sizeof( FRENamedFunction );
	*functionsToSet = functionMap;

    AirFlurryCtx = ctx;
}

void AirFlurryContextFinalizer(FREContext ctx) {}

void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFlurryContextInitializer; 
	*ctxFinalizerToSet = &AirFlurryContextFinalizer;
}

void AirFlurryFinalizer(void *extData) {}