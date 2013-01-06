#import "RSSFeedController.h"
#import "RSSItem.h"
#import "BrowserController.h"

@interface RSSFeedController ()
@property (nonatomic, retain) NSURL *feedURL;
@property (nonatomic, retain) SMWebRequest *request;
@property (nonatomic, retain) NSArray *items;
@end

@implementation RSSFeedController
@synthesize feedURL, request, items;

- (id)initWithRSSFeedURL:(NSURL *)URL {
    if ((self = [super init])) {
        self.feedURL = URL;
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                  target:self 
                                                                                  action:@selector(refresh)] autorelease];
        self.toolbarItems = [NSArray arrayWithObject:refresh];
    }
    return self;
}

- (void)dealloc {
    self.request = nil;
    self.items = nil;
    [super dealloc];
}

// it's a good idea for controllers to retain the requests they create for easy cancellation.
// also, implementing our own setter is the recommended practice for ensuring that our target/action listeners are safely removed.
- (void)setRequest:(SMWebRequest *)value {
    [request removeTarget:self]; // will cancel the request if it is currently loading.
    [request release], request = [value retain];
}

- (void)loadView {
    [super loadView];
    self.tableView.rowHeight = 50;
}

- (void)refresh {
    self.request = [RSSItem requestForItemsWithURL:feedURL];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [request addTarget:self action:@selector(requestComplete:) forRequestEvents:SMWebRequestEventComplete];
    [request addTarget:self action:@selector(requestError:) forRequestEvents:SMWebRequestEventError];
    [request start];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (!items) [self refresh];
    [super viewWillAppear:animated];
}

- (void)requestComplete:(NSArray *)theItems {
    self.items = theItems;
    [self.tableView reloadData];
    
    if ([self isViewLoaded])
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)requestError:(NSError *)theError {
    if ([self isViewLoaded])
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ItemTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 2;
    }
    
    RSSItem *item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.accessoryType = item.comments ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSItem *item = [items objectAtIndex:indexPath.row];
    BrowserController *itemController = [[[BrowserController alloc] initWithURL:item.link title:item.title] autorelease];
    [self.navigationController pushViewController:itemController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    RSSItem *item = [items objectAtIndex:indexPath.row];
    BrowserController *itemController = [[[BrowserController alloc] initWithURL:item.comments title:item.title] autorelease];
    [self.navigationController pushViewController:itemController animated:YES];
}

@end
