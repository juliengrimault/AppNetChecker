//
//  XIGTwitterUsersTableViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUsersTableViewController.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterUserCell.h"

static NSString * const CellIdentifier = @"TwitterUserCell";

@interface XIGTwitterUsersTableViewController ()
@property (nonatomic, strong) NSMutableArray* mutableFriends;
@end

@implementation XIGTwitterUsersTableViewController
#pragma mark - Properties
- (XIGTwitterClient *)twitterClient
{
    if(!_twitterClient) {
        _twitterClient = [XIGTwitterClient sharedClient];
    }
    return _twitterClient;
}

- (NSArray*)friends
{
    return [self.mutableFriends copy];
}

- (UIActivityIndicatorView *)activityIndicator
{
    return (UIActivityIndicatorView *)[self.toolbarItems[0] customView];
}

- (UILabel *)friendsCountLabel
{
    return (UILabel *)[self.toolbarItems[1] customView];
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mutableFriends = [NSMutableArray array];
    [self registerTableViewCell];
    [self configureToolBar];
    [self fetchFriends];
}

- (void)registerTableViewCell
{
    UINib *nib = [UINib nibWithNibName:@"XIGTwitterUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
}

- (void)configureToolBar
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    
    UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
    friendsCountLabel.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:friendsCountLabel];
    self.toolbarItems = @[item, item2];
}

- (void)fetchFriends
{
    RACSignal* friends = [self.twitterClient friends];
    @weakify(self);
    [friends subscribeNext:^(NSArray* nextFriends) {
        @strongify(self);
        
        NSMutableArray* insertedIndexPath = [NSMutableArray arrayWithCapacity:nextFriends.count];
        for (int i = 0; i < nextFriends.count; ++i) {
            NSIndexPath* path = [NSIndexPath indexPathForItem:i+self.mutableFriends.count  inSection:0];
            [insertedIndexPath addObject:path];
        }
        [self.mutableFriends addObjectsFromArray:nextFriends];
        [self.tableView insertRowsAtIndexPaths:insertedIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.friendsCountLabel.text = [NSString localizedStringWithFormat:@"%d friends", self.mutableFriends.count];
    } completed:^{
        @strongify(self);
        [self.activityIndicator stopAnimating];
        NSArray *newToolBarItems = @[self.toolbarItems[1]];
        [self setToolbarItems:newToolBarItems animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutableFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XIGTwitterUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XIGTwitterUser* user = self.mutableFriends[indexPath.row];
    [cell bindUser:user];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
