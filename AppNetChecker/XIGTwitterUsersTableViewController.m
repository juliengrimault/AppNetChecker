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

- (NSMutableArray*)mutableFriends
{
    if (!_mutableFriends) {
        _mutableFriends = [[NSMutableArray alloc] init];
    }
    return _mutableFriends;
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerTableViewCell];
    [self fetchFriends];
}

- (void)registerTableViewCell
{
    UINib *nib = [UINib nibWithNibName:@"XIGTwitterUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
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
