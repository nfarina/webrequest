#import "ItemController.h"

@interface ItemController ()

@property (nonatomic, retain) Item *item;

@end

@implementation ItemController

@synthesize item;

- (id)initWithItem:(Item *)theItem {
    if ((self = [super init])) {
        self.item = theItem;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc {
    self.item = nil;
	[super dealloc];
}

- (void)loadView {
    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    titleLabel.text = item.title;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.view = webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [webView loadRequest:[NSURLRequest requestWithURL:item.link]];
}

@end
