#import "HomeView.h"

@implementation HomeView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	NSString *why = @"This is the home controller. The only reason it exists is so we can go back and forth between it and a list controller whose items are loaded over HTTP using web request.";
	
	CGRect inset = {
		.size = { .width = rect.size.width - 40, .height = rect.size.height - 40 }, 
		.origin = { .x = rect.origin.x + 20, .y = rect.origin.y + 20 } 
	};
	
	[why drawInRect:inset withFont:[UIFont systemFontOfSize:10] lineBreakMode:UILineBreakModeWordWrap];
}

@end
