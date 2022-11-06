//
//  main.m
//  crashdump
//
//  Created by Dave MacLachlan on 11/6/22.
//

#import <Foundation/Foundation.h>

// Private API for turning crash reports into dictionaries.
// This is valid for at least MacOS 12 and 13.
// This was extracted from:
// /System/Library/PrivateFrameworks/OSAnalytics.framework/Versions/A/OSAnalytics
@interface OSALegacyXform : NSObject
// Takes in a crash report file pointed to by url and returns a dictionary with either
// OSATransformResultReport or OSATransformResultError keys.
+ (NSDictionary<NSString *, id> *)transformURL:(NSURL *)url options:(id)options;
@end

// These are the keys for the dictionary created by OSALegacyXform.
extern NSString *OSATransformResultError;
extern NSString *OSATransformResultReport;

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    if (argc != 2) {
      printf("crashdump <crashreportpath>\n");
      return 1;
    }
    NSString *path = [NSString stringWithUTF8String:argv[1]];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSDictionary<NSString *, id> *output = [OSALegacyXform transformURL:url options:nil];
    NSString *report = output[OSATransformResultReport];
    if (report) {
      printf("%s", report.UTF8String);
      return 0;
    }
    // uh-oh error occurred converting crash.
    // Try to output something with gcc error syntax if we are using this in a script.
    NSError *outputError = output[OSATransformResultError];
    if (outputError) {
      printf("%s: error: %s\n", argv[1], outputError.localizedDescription.UTF8String);
    } else {
      printf("%s: error: Unable to parse file\n", argv[1]);
    }
  }
  return 1;
}
