#import "BrowserController.h"

@interface BrowserController ()
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSURL *url;
@end

@implementation BrowserController
@synthesize webView, url;

- (id)initWithURL:(NSURL *)theURL title:(NSString *)title {
    if ((self = [super init])) {
        self.url = theURL;
        
        // custom navigation title label so we can fit two lines
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        UIBarButtonItem *action = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self 
                                                                                 action:@selector(actionItemTapped)] autorelease];
        
        self.toolbarItems = [NSArray arrayWithObject:action];
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.url = nil;
	[super dealloc];
}

- (void)loadView {
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    
    self.view = webView;
}

- (void)viewDidUnload {
    self.webView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark Action Sheet

- (void)actionItemTapped {
	UIActionSheet *addSheet = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil
											 destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
	
	[addSheet addButtonWithTitle:@"Open in Safari"];
	[addSheet addButtonWithTitle:@"Cancel"];
	[addSheet setCancelButtonIndex:[addSheet numberOfButtons] - 1];
	[addSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	[addSheet showFromToolbar:self.navigationController.toolbar];	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([action isEqualToString:@"Open in Safari"]) {
		[[UIApplication sharedApplication] openURL:webView.request.URL];
	}
}

@end
