
@interface BrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

- (id)initWithURL:(NSURL *)url title:(NSString *)title;

@end
