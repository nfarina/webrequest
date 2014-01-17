#import "SMURLImageView.h"
#import "SMWebRequest.h"

@interface SMURLImageView ()
@property (nonatomic, retain) SMWebRequest *request;
@end

@implementation SMURLImageView

- (id)initWithImageURL:(NSURL *)URL {
	if (self = [self initWithImage:nil highlightedImage:nil]) {
		self.imageURL = URL;
	}
	return self;
}

- (void)setImageURL:(NSURL *)URL {
	if (![self.imageURL isEqual:URL]) {
		
        [self.request cancel]; // if one is in progress
        
        _imageURL = [URL copy]; // have to call copy ourselves; underlying var won't have copy attribute like the property
		
		// clear out the existing image
		self.image = nil;
		self.request = URL ? [SMWebRequest requestWithURL:URL delegate:nil context:nil] : nil;
		[self.request addTarget:self action:@selector(imageLoaded:) forRequestEvents:SMWebRequestEventComplete];
		[self.request addTarget:self action:@selector(imageError:) forRequestEvents:SMWebRequestEventError];
		[self.request start];
	}
}

- (void)imageLoaded:(NSData *)data {
    
	self.image = [[UIImage alloc] initWithData:data];
    
    if (self.image && !self.disableAutoSizeAdjustment)
        self.frame = (CGRect) { .origin = self.frame.origin, .size = self.image.size };
	
	if ([self.delegate respondsToSelector:@selector(URLImageViewDidLoadImage:)])
		[self.delegate URLImageViewDidLoadImage:self];
}

- (void)imageError:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(URLImageView:didFailLoadWithError:)])
        [self.delegate URLImageView:self didFailLoadWithError:error];
}

@end
