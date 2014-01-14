#import "RSSFeedController.h"
#import "RSSItem.h"
#import "BrowserController.h"
#import "SMURLImageView.h"

@interface RSSFeedController ()
@property (nonatomic, strong) NSURL *feedURL;
@property (nonatomic, strong) SMWebRequest *request;
@property (nonatomic, strong) NSArray *items;
@end

@implementation RSSFeedController

- (id)initWithRSSFeedURL:(NSURL *)URL {
    if ((self = [super init])) {
        self.feedURL = URL;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
        
        UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                  target:self 
                                                                                  action:@selector(refresh)];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        
        SMURLImageView *imageView = [[SMURLImageView alloc] initWithImageURL:[NSURL URLWithString:@"https://news.ycombinator.com/y18.gif"]];
        UIBarButtonItem *logo = [[UIBarButtonItem alloc] initWithCustomView:imageView];
        
        self.toolbarItems = @[refresh, flexibleSpace, logo];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.tableView.rowHeight = 50;
}

- (void)refresh {
    [self.request cancel]; // in case one was running already
    self.request = [RSSItem requestForItemsWithURL:self.feedURL];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.request addTarget:self action:@selector(requestComplete:) forRequestEvents:SMWebRequestEventComplete];
    [self.request addTarget:self action:@selector(requestError:) forRequestEvents:SMWebRequestEventError];
    [self.request start];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (!self.items) [self refresh];
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
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ItemTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 2;
    }
    
    RSSItem *item = (self.items)[indexPath.row];
    cell.textLabel.text = item.title;
    cell.accessoryType = item.comments ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSItem *item = (self.items)[indexPath.row];
    BrowserController *itemController = [[BrowserController alloc] initWithURL:item.link title:item.title];
    [self.navigationController pushViewController:itemController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    RSSItem *item = (self.items)[indexPath.row];
    BrowserController *itemController = [[BrowserController alloc] initWithURL:item.comments title:item.title];
    [self.navigationController pushViewController:itemController animated:YES];
}

@end
