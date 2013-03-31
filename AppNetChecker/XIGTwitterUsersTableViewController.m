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
#import "XIGUserMatcher.h"
#import "NSIndexPath+XIGRange.h"
#import "UIBarButtonItem+XIGItem.h"
#import "XIGTwitAppClient.h"
#import "RACSignal+AggregateReporting.h"

static NSString * const CellIdentifier = @"TwitterUserCell";

@interface XIGTwitterUsersTableViewController ()
@end

@implementation XIGTwitterUsersTableViewController
#pragma mark - Properties

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

    RACSignal *userMatchersSignal = [[self.twittAppClient userMatchers] deliverOn:[RACScheduler mainThreadScheduler]];
    [self configureLabelsSignal:userMatchersSignal];
    [self configureTableView:userMatchersSignal];
}

- (void)registerTableViewCell
{
    UINib *nib = [UINib nibWithNibName:@"XIGTwitterUserCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    self.tableView.rowHeight = [XIGTwitterUserCell rowHeight];
}

- (void)configureToolBar
{
    UIBarButtonItem *twitterLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
    _twitterLoadingIndicator = (UIActivityIndicatorView*) twitterLoadingItem.customView;

    
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

    UIBarButtonItem *appNetLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
    _appNetLoadingIndicator = (UIActivityIndicatorView*) twitterLoadingItem.customView;
    
    self.toolbarItems = @[twitterLoadingItem, item2, item3, item4, appNetLoadingItem];
}

- (void)configureLabelsSignal:(RACSignal *)userMatchersSignal {

    // stop when all the twitter request have been made
    RACSignal *stopTrigger = [userMatchersSignal sequenceNext:^RACSignal * {
        return [RACSignal return:@YES];
    }];
    RACSignal * matchersArray = [RACAbleWithStart(self.userMatchers) takeUntil:stopTrigger];
    RAC(self.friendsCountLabel.text) =[matchersArray map:^id(NSArray *users) {
        return [NSString localizedStringWithFormat:@"%d friends", users.count];
    }];

    RACSignal *appNetUsersSignal = [[[[userMatchersSignal flattenMap:^RACStream *(NSArray *newMatchers) {
        NSArray *appNetUsers = [newMatchers mtl_mapUsingBlock:^id(XIGUserMatcher *m) {
            return m.appNetUser;
        }];
        return [appNetUsers.rac_sequence signal];
    }] flatten] setNameWithFormat:@"App.net Users"] logAll];

    RACSignal *appNetUserCount = [[[[appNetUsersSignal aggregateProgressWithStart:@0 combine:^id(NSNumber *current, XIGAppNetUser *u) {
        NSUInteger count = [current unsignedIntegerValue];
        if (u != nil) count++;
        return @(count);
    }] throttle:1] setNameWithFormat:@"App.net count"] logAll];

//    RAC(self.friendsFoundCountLabel.text) = [[appNetUserCount throttle:1] map:^id(NSNumber *count) {
//        return [NSString localizedStringWithFormat:@"%@ found.", count];
//    }];
    [appNetUserCount subscribeNext:^(NSNumber *count) {
        self.friendsFoundCountLabel.text = [NSString localizedStringWithFormat:@"%@ found.", count];
    } completed:^{
        [self.appNetLoadingIndicator stopAnimating];
    }];
}

- (void)configureTableView:(RACSignal *)userMatchersSignal
{
    @weakify(self);
    [userMatchersSignal subscribeNext:^(NSArray *matchersToAdd) {
        @strongify(self);
        NSRange insertionRange = NSMakeRange(self.userMatchers.count, matchersToAdd.count);
        NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:insertionRange];

        [self insertUserMatchers:matchersToAdd atIndexes:insertionIndexes];//use this to trigger KVO notifications

        NSArray *insertedIndexPaths = [NSIndexPath indexPathsInSection:0 range:insertionRange];
        [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationNone];

    }                       completed:^{
        @strongify(self);
        [self stopLoadingIndicator];
    }];
}

- (void)stopLoadingIndicator {
    [self.twitterLoadingIndicator stopAnimating];
    NSArray *newToolBarItems = [self.toolbarItems mtl_arrayByRemovingFirstObject]; // remove the loading indicator
    [self setToolbarItems:newToolBarItems animated:YES];
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
