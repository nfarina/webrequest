#import "RSSItemController.h"

@interface RSSItemController ()
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) RSSItem *item;
@end

@implementation RSSItemController
@synthesize webView, item;

- (id)initWithRSSItem:(RSSItem *)theItem {
    if ((self = [super init])) {
        self.item = theItem;
        
        // custom navigation title label so we can fit two lines
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.text = item.title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        // toolbar
        UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIBarButtonItem *action = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self 
                                                                                 action:@selector(actionItemTapped)] autorelease];
        
        self.toolbarItems = [NSArray arrayWithObjects:space, action, nil];
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
    self.item = nil;
	[super dealloc];
}

- (void)loadView {
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    webView.scalesPageToFit = YES;
    
    self.view = webView;
}

- (void)viewDidUnload {
    self.webView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [webView loadRequest:[NSURLRequest requestWithURL:item.link]];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
