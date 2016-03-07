#import "OverlayView.h"

@implementation OverlayView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        imageView = [[UIImageView alloc] initWithFrame: CGRectMake(130, 130, 100, 60)];
        imageView.image = [UIImage imageNamed: @"moveon"];
        [self addSubview:imageView];
    }
    return self;
}

-(void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    if(mode == GGOverlayViewModeLeft) {
        imageView.image = [UIImage imageNamed:@"moveon"];
        imageView.frame = CGRectMake(130, 130, 100, 60);
    } else {
        imageView.image = [UIImage imageNamed:@"connect"];
        imageView.frame = CGRectMake(-30, 130, 100, 60);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
