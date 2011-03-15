#import "SMWebRequest.h"

@interface ListController : UITableViewController {
    NSArray *items;
    SMWebRequest *request;
}

- (id)initListController;

@end
