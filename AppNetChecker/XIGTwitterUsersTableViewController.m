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
#import "NSIndexPath+XIGRange.h"

static NSString * const CellIdentifier = @"TwitterUserCell";

@interface XIGTwitterUsersTableViewController ()
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

- (void)insertUserMatchers:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.userMatchers insertObjects:array atIndexes:indexes];
}

- (void)removeUserMatchersAtIndexes:(NSIndexSet *)indexes
{
    [self.userMatchers removeObjectsAtIndexes:indexes];
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userMatchers = [NSMutableArray array];
    [self registerTableViewCell];
    [self configureToolBar];
    [self configureLabelsSignal];
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
    
    UILabel *friendsFoundCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
    friendsFoundCountLabel.backgroundColor = [UIColor clearColor];
    _friendsFoundCountLabel = friendsFoundCountLabel;
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithCustomView:friendsFoundCountLabel];
    
    self.toolbarItems = @[item, item2,item4];
}

- (void)configureLabelsSignal
{
    RACSignal* userMatchers = RACAbleWithStart(self.userMatchers);
    RAC(self.friendsCountLabel.text) = [userMatchers map:^id(NSArray* users) {
            return [NSString localizedStringWithFormat:@"%d friends", users.count];
    }];
    
    RACSignal *appNetUserCount = [userMatchers flattenMap:^RACStream *(id newUsers) {
        NSArray *signals = [newUsers mtl_mapUsingBlock:^id(XIGUserMatcher *u) {
            return u.appNetUser;
        }];
        return [[RACSignal combineLatest:signals] map:^id(RACTuple *tuple) {
            NSArray *nonNilAppNetUsers = [[tuple allObjects] mtl_filterUsingBlock:^BOOL(id obj) {
                return ![obj isEqual:[RACTupleNil tupleNil]];
            }];
            return @(nonNilAppNetUsers.count);
        }];
    }];
    
    RAC(self.friendsFoundCountLabel.text) = [appNetUserCount map:^id(NSNumber *count) {
        return [NSString localizedStringWithFormat:@"%@ found.", count];
    }];
}

- (void)fetchFriends
{
    RACSignal* friends = [[self.twitterClient friends] deliverOn:[RACScheduler mainThreadScheduler]];
    [friends subscribeNext:^(NSArray* nextFriends) {
        NSRange insertionRange = NSMakeRange(self.userMatchers.count, nextFriends.count);
        NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:insertionRange];

        NSArray* matchersToAdd = [nextFriends mtl_mapUsingBlock:^id(id obj) {
            return [[XIGUserMatcher alloc] initWithTwitterUser:obj appNetClient:self.appNetClient];
        }];

        [self insertUserMatchers:matchersToAdd atIndexes:insertionIndexes];//use this to trigger KVO notifications
        
        NSArray* insertedIndexPaths = [NSIndexPath indexPathsInSection:0 range:insertionRange];
        [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } completed:^{
        [self.activityIndicator stopAnimating];
        NSArray *newToolBarItems = [self.toolbarItems mtl_arrayByRemovingFirstObject]; // remove the loading indicator
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
