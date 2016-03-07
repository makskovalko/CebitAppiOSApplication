#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize information;
@synthesize overlayView;
@synthesize image;
@synthesize position;
@synthesize expertIn;
@synthesize lookingForExpertsIn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
#warning placeholder stuff, replace with card-specific information {
        //Create label for user name
        
        information = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, self.frame.size.width, 100)];
        information.text = @"no info given";
        [information setTextAlignment:NSTextAlignmentCenter];
        information.textColor = [UIColor blackColor];
        information.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        //Create label for user position
        
        position = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, self.frame.size.width, 150)];
        position.text = @"no info given";
        [position setTextAlignment:NSTextAlignmentCenter];
        position.textColor = [UIColor blackColor];
        
        expertIn = [[UILabel alloc] initWithFrame:CGRectMake(0, 225, self.frame.size.width, 225)];
        expertIn.text = @"no info given";
        expertIn.frame = CGRectMake(0, 250, self.frame.size.width, 40);
        [expertIn setTextAlignment:NSTextAlignmentLeft];
        expertIn.textColor = [UIColor whiteColor];
        expertIn.backgroundColor = [UIColor grayColor];
        
        lookingForExpertsIn = [[UILabel alloc] initWithFrame:CGRectMake(0, 225, self.frame.size.width, 225)];
        lookingForExpertsIn.text = @"no info given";
        lookingForExpertsIn.frame = CGRectMake(0, 291, self.frame.size.width, 40);
        [lookingForExpertsIn setTextAlignment:NSTextAlignmentLeft];
        lookingForExpertsIn.textColor = [UIColor whiteColor];
        lookingForExpertsIn.backgroundColor = [UIColor grayColor];
        
        UIImage *moveOnImage = [UIImage imageNamed: @"ico-move-on-0"];
        UIImage *connectImage = [UIImage imageNamed: @"ico-connect"];
        
        UITapGestureRecognizer *moveOnTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(leftClickAction)];
        [moveOnTap setNumberOfTapsRequired: 1];
        
        UITapGestureRecognizer *connectTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(rightClickAction)];
        connectTap.numberOfTapsRequired = 1;
        
        UIImageView *moveOnBtn = [[UIImageView alloc] initWithFrame: CGRectMake(moveOnImage.size.width, frame.size.height - 60, moveOnImage.size.width * 0.5, moveOnImage.size.height * 0.5)];
        [moveOnBtn setImage: moveOnImage];
        [moveOnBtn setUserInteractionEnabled: YES];
        [moveOnBtn setGestureRecognizers: [NSArray arrayWithObject: moveOnTap]];
        
        UIImageView *connectBtn = [[UIImageView alloc] initWithFrame: CGRectMake(frame.size.width - connectImage.size.width, frame.size.height - 60, connectImage.size.width * 0.5, connectImage.size.height * 0.5)];
        [connectBtn setImage: connectImage];
        [connectBtn setUserInteractionEnabled: YES];
        [connectBtn setGestureRecognizers: [NSArray arrayWithObject: connectTap]];
        
        UIView *labelsView = [[UIView alloc] init];
        
        UILabel *moveOnLabel = [[UILabel alloc] initWithFrame: CGRectMake(moveOnImage.size.width - 20, frame.size.height - 50, 100, 50)];
        [moveOnLabel setText: @"move on"];
        [labelsView addSubview: moveOnLabel];
        
        UILabel *connectLabel = [[UILabel alloc] initWithFrame: CGRectMake(frame.size.width - connectImage.size.width - 10, frame.size.height - 50, 100, 50)];
        [connectLabel setText: @"connect"];
        [labelsView addSubview: connectLabel];

        self.backgroundColor = [UIColor whiteColor];
#warning placeholder stuff, replace with card-specific information }
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:panGestureRecognizer];
        [self addSubview:information];
        [self addSubview:position];
        [self addSubview:expertIn];
        [self addSubview:lookingForExpertsIn];
        [self addSubview:moveOnBtn];
        [self addSubview:connectBtn];
        [self addSubview:labelsView];
        
        [self addGestureRecognizer:panGestureRecognizer];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
    }
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    
    overlayView.alpha = MIN(fabsf(distance)/100, 1);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         if (self.superview){
                             [self removeFromSuperview];
                         }
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}



@end