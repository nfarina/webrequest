#import "SMWebRequest.h"

@interface ListController : UITableViewController <SMWebRequestDelegate> {
    NSArray *items;
    SMWebRequest *request;
}

- (id)initListController;

@end
