#import "HomeController.h"

@implementation HomeController

- (id)initHomeController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = @"Home";
	}
	return self;
}

- (void)loadView {
	self.view = homeView = [[[HomeView alloc] initWithFrame:CGRectZero] autorelease];
}



@end
