
// SMWebRequest encapsulates a single HTTP request and response. It is designed to be less verbose
// and simpler to use than NSURLConnection. The server response is buffered completely into memory
// then passed back to event listeners as NSData. Optionally, you can specify a delegate which
// can process the NSData in some way on a background thread then return something else.

enum {
    SMWebRequestEventComplete  = 1 << 0, // selector will be passed the result pointer
    SMWebRequestEventError     = 1 << 1, // selector will be passed a pointer to NSError instance
    SMWebRequestEventAllEvents = 0xFFFFFFFF
};
typedef NSUInteger SMWebRequestEvents;

@protocol SMWebRequestDelegate;

@interface SMWebRequest : NSObject {
@private
	id<SMWebRequestDelegate> delegate; // not retained
	id context;	// retained for the lifetime of the web request

	NSMutableArray *targetActions;
	NSURLConnection *connection;
	NSURLRequest *request;
	NSURLResponse *response;
	NSMutableData *data;
	struct {
		unsigned int started:1;
		unsigned int cancelled:1;
	} requestFlags;
}

@property (nonatomic, readonly, retain) NSURLRequest *request;
@property (nonatomic, readonly, retain) NSURLResponse *response;

// Designated initializer.
- (id)initWithURLRequest:(NSURLRequest *)request delegate:(id<SMWebRequestDelegate>)delegate context:(id)context;

// Convenience creators.
+ (SMWebRequest *)requestWithURL:(NSURL *)url;
+ (SMWebRequest *)requestWithURL:(NSURL *)url delegate:(id<SMWebRequestDelegate>)delegate context:(id)context;
+ (SMWebRequest *)requestWithURLRequest:(NSURLRequest *)request delegate:(id<SMWebRequestDelegate>)delegate context:(id)context;

- (void)start;
- (void)cancel;

// register interest. does not retain target. action can take one or two arguments; 
// first is the result object returned by the delegate, second is the context.
- (void)addTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)event;

// pass in NULL for the action to remove all actions for that target.
// if there are no more target/actions, loading/processing will be cancelled.
- (void)removeTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)event;
- (void)removeTarget:(id)target; // all actions+events

@end

@protocol SMWebRequestDelegate <NSObject>
@optional

// called on a background thread and result will be passed to the targets, 
// otherwise if the delegate is nil the data will be passed to the targets.
- (id)webRequest:(SMWebRequest *)webRequest resultObjectForData:(NSData *)data context:(id)context;

// both of these are called on the main thread, BEFORE the target/action listeners are called
- (void)webRequest:(SMWebRequest *)webRequest didCompleteWithResult:(id)result context:(id)context;
- (void)webRequest:(SMWebRequest *)webRequest didFailWithError:(NSError *)error context:(id)context;

@end
