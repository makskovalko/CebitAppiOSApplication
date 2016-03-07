#import <UIKit/UIKit.h>
#import "DraggableView.h"

@interface DraggableViewBackground : UIView <DraggableViewDelegate>

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

@property (retain,nonatomic)NSArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allImages; //all images of cards
@property (retain,nonatomic)NSMutableArray* positions;
@property (retain,nonatomic)NSMutableArray* expertIn;
@property (retain,nonatomic)NSMutableArray* lookingForExpertsIn;

@property (retain,nonatomic)NSMutableArray* matchesUsers;

@end