#import "AppDelegate.h"
#import "ListController.h"
#import "SMWebRequest.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	// Demonstrate how we can listen globally to web request error events, to implement a systemwide failure message. Apple likes those!
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webRequestError:) name:kSMWebRequestError object:nil];
	
	// Example 1: Make an autoreleased "set it and forget it" web request to Google.
    SMWebRequest *request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [request addTarget:self action:@selector(googleFinished:) forRequestEvents:SMWebRequestEventComplete];
    [request start];
    
	// Example 2: Make a simple but extremely nice+performant RSS reader for Hacker News! Courtesy @bvanderveen
    ListController *home = [[ListController alloc] initListController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.toolbarHidden = NO;
    nav.toolbar.barStyle = UIBarStyleBlack;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window addSubview:nav.view];
    [window makeKeyAndVisible];
}

// Callback from Example 1: we simply get an NSData with the server response.
- (void)googleFinished:(NSData *)responseData {
    NSLog(@"Got a response of %i bytes.", responseData.length);
}

// Global error handler displays a simple failure message.
- (void)webRequestError:(NSNotification *)notification {
    if (showedOfflineAlert) return;
    showedOfflineAlert = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Error" message:@"You appear to be offline. Please try again later." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

@end
