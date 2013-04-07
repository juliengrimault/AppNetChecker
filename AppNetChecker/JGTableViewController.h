//
//  JGTableViewController.h
//  TradeHero
//
//  Created by Julien Grimault on 16/2/12.
//  Copyright (c) 2012 Edenpod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JGTableViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL clearSelectionOnViewWillAppear;

- (id) initWithStyle:(UITableViewStyle)style;
@end

@interface JGTableViewController (TableView)<UITableViewDataSource, UITableViewDelegate>

@end
