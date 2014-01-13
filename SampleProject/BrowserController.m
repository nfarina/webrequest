#import "BrowserController.h"

@interface BrowserController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@end

@implementation BrowserController

- (id)initWithURL:(NSURL *)theURL title:(NSString *)title {
    if ((self = [super init])) {
        self.url = theURL;
        self.title = title;
        
        // custom navigation title label so we can fit two lines
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.text = title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self 
                                                                                 action:@selector(actionItemTapped)];
        
        self.toolbarItems = @[action];
    }
    return self;
}


- (void)adjustTitleForOrientation:(UIInterfaceOrientation)orientation {
    // use our custom title view in portrait to fit two lines of text
    self.navigationItem.titleView = UIInterfaceOrientationIsPortrait(orientation) ? self.titleLabel : nil;
}

- (void)loadView {
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    self.view = self.webView;
}

- (void)viewDidUnload {
    self.webView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}

@end
