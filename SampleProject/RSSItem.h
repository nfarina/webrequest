#import "SMXMLDocument.h"
#import "SMWebRequest.h"

@interface RSSItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *link, *comments;

// creates a new Item by parsing an XML element
+ (RSSItem *)itemWithElement:(SMXMLElement *)element;

// creates a new request that will result in an NSArray of Items.
+ (SMWebRequest *)requestForItemsWithURL:(NSURL *)URL;

@end
