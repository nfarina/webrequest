#import "BrowserController.h"

@interface BrowserController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@end

@implementation BrowserController
@synthesize titleLabel, webView, url;

- (id)initWithURL:(NSURL *)theURL title:(NSString *)title {
    if ((self = [super init])) {
        self.url = theURL;
        self.title = title;
        
        // custom navigation title label so we can fit two lines
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self 
                                                                                 action:@selector(actionItemTapped)];
        
        self.toolbarItems = [NSArray arrayWithObject:action];
    }
    return self;
}


- (void)adjustTitleForOrientation:(UIInterfaceOrientation)orientation {
    // use our custom title view in portrait to fit two lines of text
    self.navigationItem.titleView = UIInterfaceOrientationIsPortrait(orientation) ? titleLabel : nil;
}

- (void)loadView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
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
    [self adjustTitleForOrientation:self.interfaceOrientation];
    [super viewWillAppear:animated];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustTitleForOrientation:toInterfaceOrientation];
}

#pragma mark Action Sheet

- (void)actionItemTapped {
    UIActionSheet *addSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil
                                             destructiveButtonTitle:nil otherButtonTitles:nil];
    
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
