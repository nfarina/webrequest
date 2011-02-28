#import "ItemController.h"

@interface ItemController ()

@property (nonatomic, retain) SMXMLElement *item;

@end


@implementation ItemController

@synthesize item;

- (id)initWithItem:(SMXMLElement *)theItem {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.item = theItem;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)loadView {
	UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.numberOfLines = 2;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	titleLabel.text = [item childNamed:@"title"].value;
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
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[item childNamed:@"link"].value]]];
}

@end
