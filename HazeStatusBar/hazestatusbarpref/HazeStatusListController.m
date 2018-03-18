#import "HazeStatusListController.h"
#include <notify.h>

@implementation HazeStatusListController

static CFStringRef const settingIdentifier = CFSTR("com.cbangchen.hazestatusbar"); 
static CFStringRef dataSourcechangedNotification = CFSTR("com.cbangchen.hazestatusbar/dataSourcechanged");

- (NSArray *)specifiers {
    NSArray *specifiersArr = [self loadSpecifiersFromPlistName:@"Root" target:self];
    self.specifiers = (NSMutableArray *)specifiersArr;
    [self loadPreferences];
    return specifiersArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addFooterView];
}

- (void)addFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 144)];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/HazeStatusBarPref.bundle"];
    UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"haze_bottom" ofType:@"png"]];
    CGSize size = image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - size.width) / 2,
                                                                           20,
                                                                           size.width,
                                                                           size.height)];
    imageView.image = image;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [footerView addSubview:imageView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               imageView.frame.origin.y + imageView.frame.size.height + 4,
                                                               self.view.frame.size.width,
                                                               24)];
    label.text = @"HazeStatusBar";

    if ([UIFont instancesRespondToSelector:@selector(systemFontOfSize:weight:)]) {
        label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    } else {
        label.font = [UIFont boldSystemFontOfSize:20];
    }

    label.textColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [footerView addSubview:label];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      label.frame.origin.y + label.frame.size.height,
                                                                      self.view.frame.size.width,
                                                                      18)];
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
    versionLabel.text = @"Developed by cbangchen";
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [footerView addSubview:versionLabel];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.tableFooterView = footerView;
            tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        }
    }
}

- (void)loadPreferences {
    CFArrayRef keyList = CFPreferencesCopyKeyList(settingIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *preferences;
    if (keyList) {
        preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList,
                                                                         settingIdentifier,
                                                                         kCFPreferencesCurrentUser,
                                                                         kCFPreferencesAnyHost);
        if (!preferences) { preferences = [NSDictionary dictionary]; }
        CFRelease(keyList);
    }
}

- (void)updateDataNow {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         dataSourcechangedNotification,
                                         NULL,
                                         NULL,
                                         true);
}

- (void)restartSpringBoard {
    system("killall SpringBoard");
}

- (void)sendFeedback {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:cbangchen007@gmail.com?subject=HazeStatusBar"]];
}

- (void)paypal {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/cbangchen"]];
}

@end