#import "AppDelegate.h"
#import "SMWebRequest.h"

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(UIApplication *)application {
	
	SMWebRequest *request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
	[request addTarget:self action:@selector(googleFinished:) forRequestEvents:SMWebRequestEventComplete];
	[request start];
}

- (void)googleFinished:(NSData *)responseData {
	NSLog(@"Got a response of %i bytes.", responseData.length);
}

@end
