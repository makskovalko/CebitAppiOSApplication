//
//  DialogsTableCell.h
//  CeBitApplication
//
//  Created by Alex Sergienko on 03.03.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface DialogsTableCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastmessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

@end
