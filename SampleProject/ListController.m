#import "ListController.h"
#import "ItemController.h"
#import "SMXMLDocument.h"

@interface ListController ()

@property (nonatomic, retain) SMWebRequest *request;
@property (nonatomic, retain) NSArray *items;

@end

@implementation ListController

@synthesize request, items;

// it's a good idea for controllers to retain the requests they create for easy cancellation.
- (void)setRequest:(SMWebRequest *)value {
    [request removeTarget:self]; // will cancel the request if it is currently loading.
    [request release];
    
    request = [value retain];
    [request addTarget:self action:@selector(requestComplete:) forRequestEvents:SMWebRequestEventComplete];
}

- (id)initListController {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"Hacker News";
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

- (void)loadView {
    [super loadView];
    self.tableView.rowHeight = 50;
}

- (void)refresh {
    self.request = [SMWebRequest requestWithURL:[NSURL URLWithString:@"http://news.ycombinator.com/rss"] delegate:self context:nil];
    [request start];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!items) {
        [self refresh];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

// This method is called on a background thread. Don't touch your instance members!
- (id)webRequest:(SMWebRequest *)webRequest resultObjectForData:(NSData *)data context:(id)context {
    // We do this gnarly parsing on a background thread to keep the UI responsive.
    SMXMLDocument *document = [SMXMLDocument documentWithData:data];
    
    // Select and return the bits in which we're interested.
    return [[document.root childNamed:@"channel"] childrenNamed:@"item"];
}

- (void)requestComplete:(NSArray *)theItems {
    self.items = theItems;
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemController *itemController = [[[ItemController alloc] initWithItem:[items objectAtIndex:[indexPath row]]] autorelease];
    [self.navigationController pushViewController:itemController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ItemTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 2;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[items objectAtIndex:indexPath.row] childNamed:@"title"].value;
    return cell;
}

@end
