#import <UIKit/UIKit.h>

%hook MicroMessengerAppDelegate
- (void)handleOpenURL:(NSURL *)url bundleID:(NSString *)bundleID {
  if ([url.absoluteString containsString:@"cbangchen/WXAppShortCutGenerator/"]) {
    NSArray *stringArray = [url.absoluteString componentsSeparatedByString:@"cbangchen/WXAppShortCutGenerator/"]; 
    NSString *weAppUserName = [stringArray lastObject];

    id logic = [NSClassFromString(@"WAMainFrameTaskBarLogic") new];
    id item = [NSClassFromString(@"WAMainFrameTaskItem") new];
    if (logic && item && weAppUserName) {
      ((void(*)(id, SEL, id))objc_msgSend)(item, sel_registerName("setUserName:"), weAppUserName);
      ((void(*)(id, SEL, id, id))objc_msgSend)(logic, sel_registerName("taskBarView:didSelectTaskItem:"), nil, item);
    }
  }
%orig;
}
%end