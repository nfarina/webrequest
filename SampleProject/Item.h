#import "SMXMLDocument.h"
#import "SMWebRequest.h"

@interface Item : NSObject {
    NSString *title;
    NSURL *link;
}

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSURL *link;

- (id)initWithElement:(SMXMLElement *)element;

+ (SMWebRequest *)createItemsRequest;

@end
