#import "ItemController.h"

@interface ItemController ()

@property (nonatomic, retain) SMXMLElement *item;

@end


@implementation ItemController

@synthesize item;

- (id)initWithItem:(SMXMLElement *)theItem {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.item = theItem;
		self.title = [item childNamed:@"title"].value;
		self.toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayComments)] autorelease]
							  ,nil];
	}
	return self;
}

- (void)loadView {
	self.view = webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[item childNamed:@"link"].value]]];
}

- (void)displayComments {
	
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"start load");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"finish load");
}

@end
