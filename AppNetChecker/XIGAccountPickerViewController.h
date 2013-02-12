//
//  JGAAccountPickerViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIGTwitterAccountStore.h"

@interface XIGAccountPickerViewController : UITableViewController

@property (nonatomic, strong) XIGTwitterAccountStore* reactiveTwitter;

@property (nonatomic, readonly, copy) NSArray* accounts;
@property (nonatomic, strong) NSError* error;

- (void)refreshControlValueChanged:(UIRefreshControl*)sender;
@end
