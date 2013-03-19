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
#import "UIBarButtonItem+XIGItem.h"

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

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
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
    self.tableView.rowHeight = [XIGTwitterUserCell rowHeight];
}

- (void)configureToolBar
{
    UIBarButtonItem *item = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator = (UIActivityIndicatorView*)item.customView;

    
    UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
    friendsCountLabel.backgroundColor = [UIColor clearColor];
    friendsCountLabel.textColor = [UIColor whiteColor];
    friendsCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
    _friendsCountLabel = friendsCountLabel;
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:friendsCountLabel];
    
    
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *friendsFoundCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
    friendsFoundCountLabel.backgroundColor = [UIColor clearColor];
    friendsFoundCountLabel.textColor = [UIColor whiteColor];
    friendsFoundCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
    _friendsFoundCountLabel = friendsFoundCountLabel;
    _friendsFoundCountLabel.textAlignment = NSTextAlignmentRight;
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithCustomView:friendsFoundCountLabel];
    
    self.toolbarItems = @[item, item2, item3, item4];
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
                return ![obj isEqual:[NSNull null]];
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
    RACSignal* userMatchers = [[self.twitterClient friends] map:^id(NSArray* nextFriends) {
        NSArray* matchersToAdd = [nextFriends mtl_mapUsingBlock:^id(id obj) {
            return [[XIGUserMatcher alloc] initWithTwitterUser:obj appNetClient:self.appNetClient];
        }];
        return matchersToAdd;
    }];

    RACSignal *mainThreadUserMatchers = [userMatchers deliverOn:[RACScheduler mainThreadScheduler]];
    [mainThreadUserMatchers subscribeNext:^(NSArray* matchersToAdd) {
        NSRange insertionRange = NSMakeRange(self.userMatchers.count, matchersToAdd.count);
        NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:insertionRange];

        [self insertUserMatchers:matchersToAdd atIndexes:insertionIndexes];//use this to trigger KVO notifications

        NSArray* insertedIndexPaths = [NSIndexPath indexPathsInSection:0 range:insertionRange];
        [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    } completed: ^{
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
