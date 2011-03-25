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
        self.hidesBottomBarWhenPushed = YES;
        
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
}

@end
