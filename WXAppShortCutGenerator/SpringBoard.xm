#import "HTTPServer.h"
#import <UIKit/UIKit.h>

%hook SpringBoard
 -(void)applicationDidFinishLaunching:(UIApplication *)application { 
%orig; 
	id httpServer = [HTTPServer new];

	((void(*)(id, SEL, id))objc_msgSend)(httpServer, sel_registerName("setType:"), @"_http._tcp.");
	((void(*)(id, SEL, int))objc_msgSend)(httpServer, sel_registerName("setPort:"), 55);

  NSString *wxServerDirPath = nil;
  NSString *applicationPath = @"/var/mobile/Containers/Data/Application";
  NSArray *tempFilePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:applicationPath error:nil];

  for (NSString *obj in tempFilePaths) {
    if ([obj containsString:@"com.tencent.xin"]) {
      NSArray *handledStringsArr = [obj componentsSeparatedByString:@"/"];
      if (handledStringsArr.count) {
        wxServerDirPath = [NSString stringWithFormat:@"%@/%@/Documents/wxServerDirPath", applicationPath, handledStringsArr[0]];
        break;
      }
    }
  }

  if (wxServerDirPath.length <= 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"can't find targetFilePath, let me know by sending me a e-mail -> cbangchen007@gmail.com" delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
    [alert show];
    return;
  }

	BOOL isDirectory = false;
  BOOL dirExit = false;
  dirExit = [[NSFileManager defaultManager] fileExistsAtPath:wxServerDirPath isDirectory:&isDirectory];
  if (!dirExit || !isDirectory) {
      [[NSFileManager defaultManager] removeItemAtPath:wxServerDirPath error:nil];
      [[NSFileManager defaultManager] createDirectoryAtPath:wxServerDirPath withIntermediateDirectories:YES attributes:nil error:nil];
  }

	((void(*)(id, SEL, id))objc_msgSend)(httpServer, sel_registerName("setDocumentRoot:"), wxServerDirPath);
	((void(*)(id, SEL, id))objc_msgSend)(httpServer, sel_registerName("start:"), nil);
}
%end
