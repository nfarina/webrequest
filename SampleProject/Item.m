#import "Item.h"


@implementation Item

@synthesize title, link;

- (void)setTitle:(NSString *)value {
    [title release];
    title = [value copy];
}

- (void)setLink:(NSURL *)value {
    [link release];
    link = [value retain];
}

- (id)initWithElement:(SMXMLElement *)element {
    if (self = [super init]) {
        self.title = [element childNamed:@"title"].value;
        self.link = [NSURL URLWithString:[element childNamed:@"link"].value];
    }
    return self;
}

- (void)dealloc {
    self.title = nil;
    self.link = nil;
    [super dealloc];
}

+ (SMWebRequest *)createItemsRequest {
    NSURL *url = [NSURL URLWithString:@"http://news.ycombinator.com/rss"];
    return [SMWebRequest requestWithURL:url
                               delegate:(id<SMWebRequestDelegate>)self 
                                context:nil];
}

// This method is called on a background thread. Don't touch your instance members!
+ (id)webRequest:(SMWebRequest *)webRequest resultObjectForData:(NSData *)data context:(id)context {
    // We do this gnarly parsing on a background thread to keep the UI responsive.
    SMXMLDocument *document = [SMXMLDocument documentWithData:data];
    
    // Select the bits in which we're interested.
    NSArray *itemsXml = [[document.root childNamed:@"channel"] childrenNamed:@"item"];

    NSMutableArray *items = [NSMutableArray array];
    
    // Convert them into model objects
    for (SMXMLElement *itemXml in itemsXml) {
        [items addObject:[[[Item alloc] initWithElement:itemXml] autorelease]];
    }
    
    return items;
}

@end
