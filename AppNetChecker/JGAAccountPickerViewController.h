//
//  JGAAccountPickerViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGReactiveTwitter.h"

@interface JGAAccountPickerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) JGReactiveTwitter* reactiveTwitter;
@property (nonatomic, readonly, copy) NSArray* accounts;

@property (weak, nonatomic) IBOutlet UILabel* errorLabel;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@end
