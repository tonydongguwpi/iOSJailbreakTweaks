#include <notify.h>
#import "LSStatusBarItem.h"
#import <CoreLocation/CoreLocation.h>
#import "libactivator.h"

@interface WeatherPreferences
+ (id)sharedPreferences;
- (id)localWeatherCity;
@end

@interface City
@property (nonatomic, copy) CLLocation *location;
@end

@interface UIStatusBarTimeItemView : UIView
@end

@interface HazeStatusBarActivatorListenerInstance : NSObject <LAListener>
@end

static NSString * const kHazeStatusBarShow   = @"com.cbangchen.hazestatusbar.show";

static CFStringRef const settingIdentifier = CFSTR("com.cbangchen.hazestatusbar"); 
static CFStringRef enableChangedNotification = CFSTR("com.cbangchen.hazestatusbar/enablechanged");
static CFStringRef dataSourcechangedNotification = CFSTR("com.cbangchen.hazestatusbar/dataSourcechanged");
static NSString * const statusBarItemIdentifier = @"com.cbangchen.hazestatusbar";

static id springboardObject;
static LSStatusBarItem *statusBarItem;
static id currentAQI;
static NSTimer *timer;

static id loadPreferences();
static Boolean savePreferencesDictionary(NSString *key, id value);
static void changeStatusBar();
static id getPreferenceParm(NSString *key);
static void statusHazeDidUpdated(id aqi) ;
static void startUpdatingHazeInfo();
static void updateSettingStatus();

static id loadPreferences() {
    CFArrayRef keyList = CFPreferencesCopyKeyList(settingIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *preferences = nil;
    if (keyList) {
        preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, 
                                                                   settingIdentifier, 
                                                                   kCFPreferencesCurrentUser, 
                                                                   kCFPreferencesAnyHost);
        if (!preferences) { preferences = [NSDictionary dictionary]; }
        CFRelease(keyList);
    }
    return preferences;
}

static Boolean savePreferencesDictionary(NSString *key, id value) {
	NSMutableDictionary *preferences = [loadPreferences() mutableCopy];
	[preferences setObject:value forKey:key];
	CFPreferencesSetMultiple((CFDictionaryRef)preferences, nil, settingIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	return CFPreferencesSynchronize(settingIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

static void changeStatusBar() {
	if (statusBarItem.visible) {
		statusBarItem.visible = NO;
		savePreferencesDictionary(@"enabled", @"0");
	} else {
		statusBarItem.visible = YES;
		savePreferencesDictionary(@"enabled", @"1");
		if (!currentAQI) {
			startUpdatingHazeInfo();
		} else {
			statusBarItem.titleString = [NSString stringWithFormat:@"aqi.%@", currentAQI];
		}
	}
}

@implementation HazeStatusBarActivatorListenerInstance
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
    if ([listenerName isEqualToString:kHazeStatusBarShow] ){
		changeStatusBar();
    }
}

@end

static id getPreferenceParm(NSString *key) {
	if (!key.length) {
		return nil;
	}
	NSDictionary *preferences = loadPreferences();
	if (![[preferences allKeys] containsObject:key]) {
		return nil;
	}
	return preferences[key];
}

static void statusHazeDidUpdated(id aqi) {
	currentAQI = aqi;
	if (statusBarItem.visible) {
		statusBarItem.titleString = currentAQI == nil ? @"fetching..." : [NSString stringWithFormat:@"aqi.%@", currentAQI];
	}
}

static void startUpdatingHazeInfo() {
	//  移除旧值
	currentAQI = nil; 
	statusHazeDidUpdated(nil);

	WeatherPreferences *weatherPreferences = [%c(WeatherPreferences) sharedPreferences];
    City *localWeatherCity = [weatherPreferences localWeatherCity];
	CLLocation *location = localWeatherCity.location;
	CLLocationCoordinate2D coordinate = location.coordinate;
	[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.waqi.info/feed/geo:%.1f;%.1f/?token=7ad9fa10b8f28b6792b81e2c8e74c7f50e2c2836", coordinate.latitude, coordinate.longitude]] completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (!error) {
    		statusHazeDidUpdated([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error][@"data"][@"aqi"]);
       		NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error]);
    	}
 	}] resume];
}

static void updateSettingStatus() {
	statusBarItem.visible = [getPreferenceParm(@"enabled") boolValue];
	if (statusBarItem.visible) {
		startUpdatingHazeInfo();
	}
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;

	springboardObject = self;
	if (!statusBarItem) {
		statusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:statusBarItemIdentifier alignment:StatusBarAlignmentCenter];
		((void(*)(id, SEL, BOOL))objc_msgSend)(statusBarItem, sel_registerName("setHidesTime:"), YES);
	}

	int dataUpdateDuration = [getPreferenceParm(@"updateDuration") intValue];
	timer = [NSTimer scheduledTimerWithTimeInterval:dataUpdateDuration*60 target:self selector:@selector(timerSelector:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

	HazeStatusBarActivatorListenerInstance *HAZEALI = [HazeStatusBarActivatorListenerInstance new];
	[[LAActivator sharedInstance] registerListener:HAZEALI forName:kHazeStatusBarShow];
}

%new
- (void)timerSelector:(id)sender {
	startUpdatingHazeInfo();
}
%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    NULL, 
                                    (CFNotificationCallback)updateSettingStatus, 
                                    enableChangedNotification, 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    NULL, 
                                    (CFNotificationCallback)updateSettingStatus, 
                                    dataSourcechangedNotification, 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);
}
