#import "AppDelegate.h"
#import "RSSFeedController.h"
#import "SMWebRequest.h"
#import "SMXMLDocument.h"
#import "RSSItem.h"

@implementation AppDelegate

//- (void)downloadRSSFeed {
//    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // Hacker News
//    SMWebRequest *request = [SMWebRequest requestWithURL:url];
//    [request addTarget:self action:@selector(downloadComplete:) forRequestEvents:SMWebRequestEventComplete];
//    [request start];
//}
//
//- (void)downloadComplete:(NSData *)data {
//    SMXMLDocument *document = [SMXMLDocument documentWithData:data];
//    NSArray *items = [[document.root childNamed:@"channel"] childrenNamed:@"item"];
//    
//    // pull out the first title
//    SMXMLElement *element = [items objectAtIndex:0];
//    NSLog(@"Article: %@", [element valueWithPath:@"title"]); // prints "Article: Is RSS Dead? Discuss."
//}


//- (void)downloadRSSFeed {
//    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // Hacker News
//    SMWebRequest *request = [SMWebRequest requestWithURL:url];
//    [request addTarget:self action:@selector(downloadComplete:) forRequestEvents:SMWebRequestEventComplete];
//    [request start];
//}
//
//- (void)downloadComplete:(NSData *)data {
//    // detach a background thread to process the data
//    [self performSelectorInBackground:@selector(parseRSSFeed:) withObject:data];
//}
//
//// called in a background thread! Don't touch our instance members!
//- (void)parseRSSFeed:(NSData *)data {
//    
//    NSAutoreleasePool *pool = [NSAutoreleasePool new]; // we'll need this to do anything in Cocoa
//    
//    SMXMLDocument *document = [SMXMLDocument documentWithData:data];
//    NSArray *items = [[document.root childNamed:@"channel"] childrenNamed:@"item"];
//    
//    // back to the main thread!
//    [self performSelectorOnMainThread:@selector(parseComplete:) withObject:items waitUntilDone:NO];
//    
//    [pool release];
//}
//
//- (void)parseComplete:(NSArray *)items {
//    SMXMLElement *element = [items objectAtIndex:0];
//    NSLog(@"Article: %@", [element valueWithPath:@"title"]); // prints "Article: Twitter totally killed RSS."
//}

//- (void)downloadRSSFeed {
//    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // Hacker News
//    SMWebRequest *request = [SMWebRequest requestWithURL:url delegate:(id)[self class] context:nil];
//    [request addTarget:self action:@selector(downloadComplete:) forRequestEvents:SMWebRequestEventComplete];
//    [request start];
//}
//
//+ (id)webRequest:(SMWebRequest *)webRequest resultObjectForData:(NSData *)data context:(id)context {
//    SMXMLDocument *document = [SMXMLDocument documentWithData:data];
//    return [[document.root childNamed:@"channel"] childrenNamed:@"item"];
//}
//
//- (void)downloadComplete:(NSArray *)items {
//    SMXMLElement *element = [items objectAtIndex:0];
//    NSLog(@"Article: %@", [element valueWithPath:@"title"]); // prints "Article: Twitter hates us; back to RSS!"
//}

- (void)downloadRSSFeed {
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // Hacker News
    SMWebRequest *request = [RSSItem requestForItemsWithURL:url];
    [request addTarget:self action:@selector(downloadComplete:) forRequestEvents:SMWebRequestEventComplete];
    [request start];
}

- (void)downloadComplete:(NSArray *)items {
    RSSItem *item = [items objectAtIndex:0];
    NSLog(@"Article: %@", item.title); // prints "Article: News doesn't matter, let's get back to work."
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {

    [self downloadRSSFeed];
    return;
    
	// Demonstrate how we can listen globally to web request error events, to implement a systemwide failure message. Apple likes those!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webRequestError:) name:kSMWebRequestError object:nil];
	
	// Example 1: Make an autoreleased "set it and forget it" web request to Google.
    SMWebRequest *request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    [request addTarget:self action:@selector(googleFinished:) forRequestEvents:SMWebRequestEventComplete];
    [request start];
    
	// Example 2: Make a simple but extremely nice+performant RSS reader for Hacker News! Courtesy @bvanderveen
    
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"]; // you can really use any RSS url here
    RSSFeedController *home = [[RSSFeedController alloc] initWithRSSFeedURL:url];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.toolbarHidden = NO;
    nav.toolbar.barStyle = UIBarStyleBlack;
    
    // Mimic the HN site.
    home.title = @"Hacker News";
    home.tableView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:239.0/255.0 alpha:1];
    nav.navigationBar.tintColor = [UIColor colorWithRed:235.0/255.0 green:120.0/255.0 blue:31.0/255.0 alpha:1];
    
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
    if (displayedOfflineAlert) return;
    displayedOfflineAlert = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Error" message:@"You appear to be offline. Please try again later." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

@end
