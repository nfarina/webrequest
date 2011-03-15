#import "Item.h"

@interface ItemController : UIViewController <UIWebViewDelegate> {
    UIWebView *webView;
    Item *item;
}

- (id)initWithItem:(Item *)item;

@end
