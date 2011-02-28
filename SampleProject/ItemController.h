#import "SMXMLDocument.h"

@interface ItemController : UIViewController <UIWebViewDelegate> {
    UIWebView *webView;
    SMXMLElement *item;
}

- (id)initWithItem:(SMXMLElement *)item;

@end
