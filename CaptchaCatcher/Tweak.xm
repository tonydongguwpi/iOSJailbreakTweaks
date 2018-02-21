#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define kCoreTelephonyPath "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"
#define kIMDPersistencePath "/System/Library/PrivateFrameworks/IMDPersistence.framework/IMDPersistence"
#define kChatKitPath "/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit"

static UIWindow *window;

void (*CTTelephonyCenterAddObserver) (id, id, CFNotificationCallback, NSString*, void*, int);
id(*CTTelephonyCenterGetDefault)();
int(*IMDMessageRecordGetMessagesSequenceNumber)();

static void callback(CFNotificationCenterRef center,  
                     void *observer, CFStringRef name,  
                     const void *object, CFDictionaryRef userInfo) {
	 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	 	void *IMDPersistenceHandler = dlopen(kIMDPersistencePath, RTLD_NOW);
    	IMDMessageRecordGetMessagesSequenceNumber = (int (*)())dlsym(IMDPersistenceHandler, "IMDMessageRecordGetMessagesSequenceNumber");
    	int lastID = IMDMessageRecordGetMessagesSequenceNumber();
    	dlclose(IMDPersistenceHandler);

    	void *ChatKitHandler = dlopen(kChatKitPath, RTLD_LAZY);
    	Class CKDBMessageClass = NSClassFromString(@"CKDBMessage");
    	id msg = ((id(*)(id, SEL, int))objc_msgSend)([CKDBMessageClass new], sel_registerName("initWithRecordID:"), lastID);
    	NSString *msgText;
		if (msg) {
			 msgText = [msg valueForKey:@"_text"];
			 if (msgText.length) {
			 	[@[@"验证码", @"verification", @"validation", @"code", @"码", @"security", @"captcha", @"auth", @"identifying", @"验证"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            		if ([msgText containsString:obj]) {
            			NSRange range = [msgText rangeOfString:@"[A-Za-z0-9]{4,}(?![A-Za-z0-9])" options:NSRegularExpressionSearch];
			 			if (range.location != NSNotFound) {
			 				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			 				pasteboard.string = [msgText substringWithRange:range];
			 				
			 				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Verification code (%@) detected, already copied to the pasting board.", [msgText substringWithRange:range]] delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
    						[alert show];
						}
            		}
            		*stop = YES;
        		}];			 	
			 }
		}
		dlclose(ChatKitHandler);
    });
}

%hook SpringBoard
 -(void)applicationDidFinishLaunching:(UIApplication *)application { 
%orig; 
	window = application.keyWindow;
	void *coreTelephonyHandle = dlopen(kCoreTelephonyPath, RTLD_LAZY);
	CTTelephonyCenterGetDefault = (id (*)())dlsym(coreTelephonyHandle, "CTTelephonyCenterGetDefault");
	CTTelephonyCenterAddObserver = (void(*)(id, id, CFNotificationCallback, NSString*, void*, int))dlsym(coreTelephonyHandle, "CTTelephonyCenterAddObserver");
	CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, callback, @"kCTMessageReceivedNotification",  NULL, CFNotificationSuspensionBehaviorHold);
	dlclose(coreTelephonyHandle);
}
 %end