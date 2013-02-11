//
//  XIGAccountErrorCell.h
//  AppNetChecker
//
//  Created by Julien Grimault on 11/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIGAccountError.h"

@interface XIGAccountErrorCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* errorLabel;

- (void)bindError:(NSError*)error;

+(CGFloat)rowHeight;
@end
