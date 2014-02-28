#import "SMWebRequest.h"

//
// Utility class for tracking our target/action pairs.
//

@interface SMTargetAction : NSObject
@property (nonatomic, unsafe_unretained) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) SMWebRequestEvents events;
@end
@implementation SMTargetAction
@end

//
// WebRequest.
//

NSString *const kSMWebRequestComplete = @"SMWebRequestComplete", *const kSMWebRequestError = @"SMWebRequestError";
NSString *const SMErrorResponseKey = @"response";

@interface SMWebRequest ()
@property (nonatomic, unsafe_unretained) id<SMWebRequestDelegate> delegate;
@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSMutableArray *targetActions;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) BOOL started, cancelled;
@end

@implementation SMWebRequest

- (id)initWithURLRequest:(NSURLRequest *)theRequest delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    self = [super init];
    if (self) {
        self.request = theRequest;
        self.delegate = theDelegate;
        self.context = theContext;
        self.targetActions = [NSMutableArray array]; 
    }
    return self;
}

- (void)dealloc {
    //NSLog(@"Dealloc %@", self);
    [self cancel];
    self.delegate = nil;
}

+ (SMWebRequest *)requestWithURL:(NSURL *)theURL {
    return [SMWebRequest requestWithURL:theURL delegate:nil context:nil];
}

+ (SMWebRequest *)requestWithURL:(NSURL *)theURL delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    return [SMWebRequest requestWithURLRequest:[NSURLRequest requestWithURL:theURL] delegate:theDelegate context:theContext];
}

+ (SMWebRequest *)requestWithURLRequest:(NSURLRequest *)theRequest delegate:(id<SMWebRequestDelegate>)theDelegate context:(id)theContext {
    return [[SMWebRequest alloc] initWithURLRequest:theRequest delegate:theDelegate context:theContext];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@>", self.request.URL];
}

- (void)start {
    if (self.started) return; // subsequent calls to this method won't do anything
    
    self.started = YES;
    
    //NSLog(@"Requesting %@", self);

    self.data = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

- (void)cancel {
    if (self.cancelled) return; // subsequent calls to this method won't do anything
    
    // the only thing that can actually be "cancelled" is the NSURLConnection. Background thread processing can't be
    // cancelled since the background thread must run to completion or else you end up with god knows what on the heap.
    if (self.connection) {
        //NSLog(@"Cancelling %@", self);
        [self.connection cancel];
        self.connection = nil;
    }
    self.cancelled = YES;
    self.context = nil; // you'll never hear from us again.
}

#pragma mark Target/Action management

- (SMTargetAction *)targetActionForTarget:(id)target action:(SEL)action {
    for(SMTargetAction *ta in self.targetActions)
        if (ta.target == target && (ta.action == action || !action))
            return ta;
    
    return nil;
}

- (void)addTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)events {
    
    SMTargetAction *ta = [self targetActionForTarget:target action:action];
    
    if (!ta) {
        ta = [[SMTargetAction alloc] init];
        ta.target = target;
        ta.action = action;
        [self.targetActions addObject:ta];
    }
    
    ta.events |= events;
}

- (void)removeTarget:(id)target action:(SEL)action forRequestEvents:(SMWebRequestEvents)events {
    
    while (true) { // if you passed NULL for the action, we may have to search multiple times
        
        SMTargetAction *ta = [self targetActionForTarget:target action:action];
        
        if (!ta) break;
        
        SMWebRequestEvents toRemove = ta.events & events;
        ta.events -= toRemove;
        
        if (!ta.events)
            [self.targetActions removeObject:ta];
    }
    
    if (![self.targetActions count])
        [self cancel];
}

- (void)removeTarget:(id)target {
    [self removeTarget:target action:NULL forRequestEvents:SMWebRequestEventAllEvents];
}

- (NSMutableArray *)targetActionsForEvents:(SMWebRequestEvents)events {
    NSMutableArray *resultTargetActions = [NSMutableArray array];
    
    for(SMTargetAction *ta in self.targetActions)
        if ((ta.events & events) != 0) [resultTargetActions addObject:ta];
    
    return resultTargetActions;
}

// only call on main thread
- (void)dispatchEvents:(SMWebRequestEvents)events withArgument:(id)arg {
    // We need to disable this warning because of our use of performSelector, instead we assume that
    // the selector you give us doesn't return anything (or returns an autoreleased object that we don't need to care about)
    // See http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    for (SMTargetAction *ta in [self targetActionsForEvents:events])
        [ta.target performSelector:ta.action withObject:arg withObject:self.context];
    
    #pragma clang diagnostic pop

    // events dispatched (if any) and delegate called (if any); so we're done.
    self.context = nil;
}

- (void)dispatchComplete:(id)resultObject {
    
    // notify the delegate first
    if ([self.delegate respondsToSelector:@selector(webRequest:didCompleteWithResult:context:)])
        [self.delegate webRequest:self didCompleteWithResult:resultObject context:self.context];
    
    // notify event listeners
    [self dispatchEvents:SMWebRequestEventComplete withArgument:resultObject];
    
    // notify the world last
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMWebRequestComplete object:self];
}

- (void)dispatchError:(NSError *)error {
    
    // notify the delegate first
    if ([self.delegate respondsToSelector:@selector(webRequest:didFailWithError:context:)])
        [self.delegate webRequest:self didFailWithError:error context:self.context];
    
    // notify event listeners
    [self dispatchEvents:SMWebRequestEventError withArgument:error];
    
    // notify the world last
    NSDictionary *info = @{NSUnderlyingErrorKey: error};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSMWebRequestError object:self userInfo:info];
}

// in a background thread! don't touch our instance members!
- (void)processDataInBackground:(NSData *)theData {
    @autoreleasepool {
    
        id resultObject = theData;
        
        if ([self.delegate respondsToSelector:@selector(webRequest:resultObjectForData:context:)])
            resultObject = [self.delegate webRequest:self resultObjectForData:theData context:self.context];
        
        [self performSelectorOnMainThread:@selector(backgroundProcessingComplete:) withObject:resultObject waitUntilDone:NO];
    }
}

// back on the main thread
- (void)backgroundProcessingComplete:(id)resultObject {
    if (!self.cancelled)
		[self dispatchComplete:resultObject];
}

#pragma mark NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)newRequest redirectResponse:(NSURLResponse *)redirectResponse {
    // see if our delegate cares about this
    if ([self.delegate respondsToSelector:@selector(webRequest:willSendRequest:redirectResponse:)])
        return [self.delegate webRequest:self willSendRequest:newRequest redirectResponse:redirectResponse];
    else
        return newRequest; // let it happen
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)aResponse {
    self.response = aResponse;
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)moreData {
    [self.data appendData:moreData];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    NSLog(@"SMWebRequest's NSURLConnection failed! Error - %@ %@", error, conn);
    
    self.connection = nil;
    self.data = nil;
     // we must retain ourself before we call handlers, in case they release us!
    
    [self dispatchError:error];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    
    //NSLog(@"Finished loading %@", self);
    
     // we must retain ourself before we call handlers, in case they release us!
    
    NSInteger status = [self.response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)self.response statusCode] : 200;
    
    if (conn && self.response && status >= 400) {
        NSLog(@"Failed with HTTP status code %i while loading %@", (int)status, self);
        
        SMErrorResponse *error = [[SMErrorResponse alloc] init];
        error.response = (NSHTTPURLResponse *)self.response;
        error.data = self.data;
        
        NSMutableDictionary* details = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"Received an HTTP status code indicating failure.", NSLocalizedDescriptionKey,
                                        error, SMErrorResponseKey,
                                        nil];
        [self dispatchError:[NSError errorWithDomain:@"SMWebRequest" code:status userInfo:details]];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(webRequest:resultObjectForData:context:)]) {
            
            // neither us nor our delegate can get dealloced whilst processing on the background
            // thread or else the background thread could try to do stuff with pointers to garbage.
            // thus we need have a mechanism for keeping ourselves alive during the background
            // processing.
            
            [self performSelectorInBackground:@selector(processDataInBackground:) withObject:self.data];
        }
        else
            [self dispatchComplete:self.data];
    }
    
    self.connection = nil;
    self.data = nil; // don't keep this!
}

@end

@implementation SMErrorResponse
@end