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
#import "XIGTwitterUser.h"
#import "XIGAppNetClient.h"
#import "XIGUserMatcher.h"

static NSString * const CellIdentifier = @"TwitterUserCell";

@interface XIGTwitterUsersTableViewController ()
@property (nonatomic, strong) NSMutableArray* userMatchers;
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

- (XIGAppNetClient *)appNetClient
{
    if(!_appNetClient) {
        _appNetClient = [XIGAppNetClient sharedClient];
    }
    return _appNetClient;
}


- (NSArray *)users
{
    return [self.userMatchers copy];
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userMatchers = [NSMutableArray array];
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
    _activityIndicator = indicator;
    [indicator startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    
    UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
    friendsCountLabel.backgroundColor = [UIColor clearColor];
    _friendsCountLabel = friendsCountLabel;
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:friendsCountLabel];
    self.toolbarItems = @[item, item2];
}

- (void)fetchFriends
{
    RACSignal* friends = [[self.twitterClient friends] deliverOn:[RACScheduler mainThreadScheduler]];
    [friends subscribeNext:^(NSArray* nextFriends) {
        NSMutableArray* insertedIndexPath = [NSMutableArray arrayWithCapacity:nextFriends.count];
        for (int i = 0; i < nextFriends.count; ++i) {
            NSIndexPath* path = [NSIndexPath indexPathForItem:i+self.userMatchers.count  inSection:0];
            [insertedIndexPath addObject:path];
        }
        
        NSArray* matchersToAdd = [nextFriends mtl_mapUsingBlock:^id(id obj) {
            return [[XIGUserMatcher alloc] initWithTwitterUser:obj appNetClient:self.appNetClient];
        }];
        [self.userMatchers addObjectsFromArray:matchersToAdd];
        [self.tableView insertRowsAtIndexPaths:insertedIndexPath withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.friendsCountLabel.text = [NSString localizedStringWithFormat:@"%d friends", self.userMatchers.count];
    } completed:^{
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
    return self.userMatchers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XIGTwitterUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XIGUserMatcher* userMatcher = self.userMatchers[indexPath.row];
    [cell bindUserMatcher:userMatcher];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
