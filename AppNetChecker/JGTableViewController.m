//
//  JGTableViewController.m
//  TradeHero
//
//  Created by Julien Grimault on 16/2/12.
//  Copyright (c) 2012 Edenpod. All rights reserved.
//

#import "JGTableViewController.h"

@interface JGTableViewController ()
@property (nonatomic) UITableViewStyle style;
@end

@implementation JGTableViewController
#pragma mark - Properties
@synthesize tableView = _tableView;
@synthesize style = _style;
@synthesize clearSelectionOnViewWillAppear = _clearSelectionOnViewWillAppear;

- (void) setTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
    {
        return;
    }

    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}


#pragma mark - Init
- (void) setup
{
    _clearSelectionOnViewWillAppear = YES;
}


- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self)
    {
        _style = style;
        [self setup];
    }

    return self;
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _style = UITableViewStylePlain;
        [self setup];
    }

    return self;
}


- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView
{
    if (self.nibName)
    {
        [super loadView];
        NSAssert(self.tableView, @"tableView property was not assigned in NIB");
        return;
    }

    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:self.style];
    self.tableView = tableView;
    self.view = tableView;
    tableView.scrollsToTop = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.clearSelectionOnViewWillAppear)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in selectedRows)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

    [self.tableView reloadData];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}


- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


@end
