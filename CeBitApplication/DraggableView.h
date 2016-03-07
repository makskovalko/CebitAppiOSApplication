#import <UIKit/UIKit.h>
#import "OverlayView.h"

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

@end

@interface DraggableView : UIView

@property (weak) id <DraggableViewDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)OverlayView* overlayView;
@property (nonatomic,strong)UILabel* information; //%%% a placeholder for any card-specific information
@property (nonatomic,strong)UILabel* position;
@property (nonatomic,strong)UILabel* expertIn;
@property (nonatomic,strong)UILabel* lookingForExpertsIn;
@property (nonatomic,strong)UIImage *image; //image for card

-(void)leftClickAction;
-(void)rightClickAction;

@end