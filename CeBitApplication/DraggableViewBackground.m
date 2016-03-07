#import "DraggableViewBackground.h"
#import "AFNetworking.h"
#import "MatchingController.h"
#import "MatchScreenViewController.h"
#import <QMServices.h>
#import <Quickblox/Quickblox.h>
#import "ChatViewController.h"

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
    int cardsIterator;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 50; //%%% max number of cards loaded at any given time, must be greater than 1
//static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const int CARD_HEIGHT = 400;
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards
@synthesize allImages;
@synthesize positions;
@synthesize expertIn;
@synthesize lookingForExpertsIn;
@synthesize matchesUsers;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        //Retrieve matches users by my categories
        [self getUsersForMatch];
        
        exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth", nil]; //%%% placeholder for card-specific information
        allImages = [[NSArray alloc] initWithObjects: @"1.png", @"2.png", @"3.png", @"4.jpg", nil];
        positions = @[@"Web-Developer", @"iOS Developer", @"Android Developer", @"Java Developer"];
        expertIn = @[@"Web Development", @"iOS Development", @"Mobile Development", @"Java Development"];
        lookingForExpertsIn = @[@"Design", @"Haskell", @"Scala", @"Cloud"];
        
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        cardsIterator = 0;
        //[self loadCards];
        
    }
    return self;
}


-(void) getUsersForMatch {
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSMutableArray *lookingForExperts = [NSMutableArray arrayWithArray: (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey: @"expertInCategories"]];
    NSMutableDictionary *user = (NSMutableDictionary *)[cache objectForKey: @"user"];
    
    NSLog(@"Categories for match: %@", lookingForExperts);
    NSLog(@"User: %@", user);
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"matches/%@", user[@"id"]]];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    NSMutableArray *matchCategories = [NSMutableArray array];
    for (int i = 0; i < [lookingForExperts count]; i++)
        [matchCategories addObject: [lookingForExperts objectAtIndex: i][@"id"]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject: [matchCategories count] > 0 ? matchCategories : [NSNumber numberWithInt: -1] forKey: @"categories"];
    
    [manager POST:requestURL parameters: userData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success!");
        NSMutableArray *responseUser = (NSMutableArray *) responseObject;
        matchesUsers = responseUser;
        
        NSLog(@"Response users: %@", responseUser);
        
        [self loadCards];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
    
}

-(void) acceptMatch: (NSDictionary *) recipientUser {
    NSLog(@"Accept match");
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = (NSDictionary *)[cache objectForKey: @"user"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"matches/%@/accept", user[@"id"]]];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject: recipientUser[@"id"] forKey: @"recipient_id"];
    
    [manager POST:requestURL parameters: userData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *) responseObject;
        NSLog(@"%@", responseObject);
        NSString *approveStatus = [NSString stringWithFormat: @"%@", response[@"is_approved"]];
        NSString *status = [NSString stringWithFormat: @"%@", response[@"status"]];
       
        if ([approveStatus isEqualToString: @"1"]) {
            NSLog(@"You have a match!");
            
            UIViewController *destController = [self viewController];
            
            NSUserDefaults *tempCache = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *recipientUserData = [[NSMutableDictionary alloc] init];
            [recipientUserData setObject: recipientUser[@"id"] forKey: @"id"];
            [recipientUserData setObject: recipientUser[@"name"] forKey: @"name"];
            [recipientUserData setObject: recipientUser[@"profile_image"] forKey: @"profile_image"];
            
            [tempCache setObject: recipientUserData forKey: @"recipientUser"];
             
            [destController performSegueWithIdentifier: @"matchScreen" sender: destController];
            
        }else if([approveStatus isEqualToString: @"400"]){
           
            UIViewController *destController = [self viewController];

            NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *matchedUser = (NSMutableDictionary *)[cache objectForKey: @"recipientUser"];
            [QBRequest userWithExternalID:((NSNumber *) matchedUser[@"id"]).intValue successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
                if (user&&user.ID>0){
                   [QMServicesManager.instance.chatService createPrivateChatDialogWithOpponent:user completion:^(QBResponse *response, QBChatDialog *createdDialog) {
                        
                        if (createdDialog != nil) {
                            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            ChatViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                            controller.dialog = createdDialog;
                            controller.opponentUser = user;
                            [destController.navigationController pushViewController:controller animated:YES];
                        }else{
                            NSLog(@"Error:MatchScreenViewController:startChat response=%@",response);
                        }
                       
                    }];
                }else{
                    
                    NSLog(@"Error:MatchScreenViewController:startChat response=%@",response);
                }
                
            } errorBlock:^(QBResponse * _Nonnull response) {
                NSLog(@"Error:MatchScreenViewController:startChat errorBlock response=%@",response);
                
            }];
            
           
           
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"errror=$@",error);

    }];
    
}

- (UIViewController*)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}

-(void) declineMatcn: (NSDictionary *) recipientUser {
    NSLog(@"Decline match");
   
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = (NSDictionary *)[cache objectForKey: @"user"];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue: user[@"access_token"] forHTTPHeaderField: @"Authorization"];
    
    NSString *apiURL = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"server"];
    NSString *requestURL = [NSString stringWithFormat: @"%@%@", apiURL, [NSString stringWithFormat: @"matches/%@/decline", user[@"id"]]];
    
    NSLog(@"\nAPI URL: %@\n", requestURL);
    
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject: recipientUser[@"id"] forKey: @"recipient_id"];
    
    [manager POST:requestURL parameters: userData progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *response = (NSMutableDictionary *) responseObject;
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    //self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 485, 59, 59)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 485, 159, 59)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuButton];
    [self addSubview:messageButton];
    [self addSubview:xButton];
    [self addSubview:checkButton];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    //draggableView.
    /*draggableView.information.text = [exampleCardLabels objectAtIndex:index]; //%%% placeholder for card-specific information
    draggableView.position.text = [positions objectAtIndex:index];
    draggableView.expertIn.text = [NSString stringWithFormat: @"    Expert in: %@", [expertIn objectAtIndex:index]];
    draggableView.lookingForExpertsIn.text = [NSString stringWithFormat: @"    Looking for experts in: %@", [lookingForExpertsIn objectAtIndex:index]];*/
    
    draggableView.information.text = [matchesUsers objectAtIndex: index][@"name"];
    draggableView.position.text = [matchesUsers objectAtIndex: index][@"position"];
    
    NSArray *expertInArray = [matchesUsers objectAtIndex: index][@"expertInCategories"];
    NSArray *lookingInArray = [matchesUsers objectAtIndex: index][@"lookingForExperts"];
    
    NSLog(@"Expert In Array: %@", expertInArray);
    NSLog(@"Looking for In Array: %@", lookingInArray);
    
    
    NSMutableArray *expCatLabels = [[NSMutableArray alloc] init];
    NSMutableArray *lookingCatLabels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [expertInArray count]; i++)
        [expCatLabels addObject: [expertInArray objectAtIndex: i][@"name"]];
    
    for (int i = 0; i < [lookingInArray count]; i++)
        [lookingCatLabels addObject: [lookingInArray objectAtIndex: i][@"name"]];
    
    NSString *expertCategories = [expCatLabels componentsJoinedByString: @", "];
    NSString *lookingCategories = [lookingCatLabels componentsJoinedByString: @", "];
    
    
    NSString *expertString = [NSString stringWithFormat: @"%@ %@", @"    Expert in:", [expertInArray count] == 0 ? @"No selected categories" : expertCategories];
    NSString *lookingString = [NSString stringWithFormat: @"%@ %@", @"    Looking for experts in: ", [lookingInArray count] == 0 ? @"No selected categories" : lookingCategories];
    
    
    NSMutableAttributedString *expString = [[NSMutableAttributedString alloc] initWithString: expertString];
    [expString addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range: NSMakeRange([expertString rangeOfString: @":"].location + 1, expertCategories.length + 1)];
    draggableView.expertIn.attributedText = expString;
    
    NSMutableAttributedString *lookStr = [[NSMutableAttributedString alloc] initWithString: lookingString];
    [lookStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range: NSMakeRange([lookingString rangeOfString: @":"].location + 1, lookingCategories.length + 1)];
    
    draggableView.lookingForExpertsIn.attributedText = lookStr;
    
    
    //draggableView.expertIn.text = [NSString stringWithFormat: @"    Expert in: %@", @""];
    
    
    //draggableView.lookingForExpertsIn.text = [NSString stringWithFormat: @"    Looking for experts in: %@", @""];

    
    int imageSize = 150;
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat width = screen.size.width;
    CGFloat height = screen.size.height;

    //UIImage *uiImage = [UIImage imageNamed: [allImages objectAtIndex: index]];
    
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(dispatchQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [matchesUsers objectAtIndex: index][@"profile_image"]]];
            UIImage *uiImage = [UIImage imageWithData: imageData];
            CGSize size = CGSizeMake(imageSize, imageSize);
            uiImage = [self image: uiImage scaledToSize: size];

            //NSMutableDictionary *currentUser = (NSMutableDictionary *)[matchesUsers objectAtIndex: index];
            NSString *code = @"OK";
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(showUserProfile:)];
            gestureRecognizer.numberOfTapsRequired = 1;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(draggableView.frame.size.width / 2 - uiImage.size.width / 2, 10, imageSize, imageSize)];
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.layer.masksToBounds = YES;
            [imageView setImage:[UIImage imageWithData: imageData]];
            imageView.backgroundColor = [UIColor redColor];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setUserInteractionEnabled: YES];
            [imageView addGestureRecognizer: gestureRecognizer];
            [imageView setTag: index];
            
            [draggableView addSubview:imageView];
        });
    });
    
    
    [self bringSubviewToFront: draggableView];
    
    draggableView.delegate = self;
    return draggableView;
}

- (void) showUserProfile: (UIGestureRecognizer *) sender {
    UIViewController *destController = [self viewController];
    
    NSDictionary *user = [matchesUsers objectAtIndex: sender.view.tag];
    NSLog(@"Current user: %@", user);
    NSMutableDictionary *matchUser = [[NSMutableDictionary alloc] init];
    
    [matchUser setObject: user[@"id"] forKey: @"id"];
    [matchUser setObject: user[@"email"] forKey: @"email"];
    [matchUser setObject: user[@"name"] forKey: @"name"];
    [matchUser setObject: user[@"country"] forKey: @"country"];
    [matchUser setObject: user[@"place_of_work"] forKey: @"place_of_work"];
    [matchUser setObject: user[@"position"] forKey: @"position"];
    [matchUser setObject: user[@"profile_image"] forKey: @"profile_image"];
    [matchUser setObject: user[@"about"] != nil ? user[@"about"] : @"" forKey: @"about"];
    [matchUser setObject: user[@"expertInCategories"] forKeyedSubscript: @"expertInCategories"];
    [matchUser setObject: user[@"lookingForExperts"] forKeyedSubscript: @"lookingForExperts"];
    
    [[NSUserDefaults standardUserDefaults] setObject: matchUser forKey: @"matchUserProfile"];
    
    [[NSUserDefaults standardUserDefaults] setObject: @"userProfileInfo" forKey: @"userProfileInfo"];
    [destController performSegueWithIdentifier: @"userProfileInfo" sender: destController];
}

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([matchesUsers count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[matchesUsers count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[matchesUsers count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
            
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    NSLog(@"%@", [matchesUsers objectAtIndex: cardsIterator]);
    [self declineMatcn: [matchesUsers objectAtIndex: cardsIterator]];
    cardsIterator++;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [matchesUsers count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[matchesUsers objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    NSLog(@"%@", [matchesUsers objectAtIndex: cardsIterator]);
    [self acceptMatch: [matchesUsers objectAtIndex: cardsIterator]];
    cardsIterator++;
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    NSLog(@"Right");
    
    if (cardsLoadedIndex < [matchesUsers count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[matchesUsers objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
//        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }/* else if (cardsLoadedIndex == [matchesUsers count]) {
        [self loadCards];
    }*/

}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
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