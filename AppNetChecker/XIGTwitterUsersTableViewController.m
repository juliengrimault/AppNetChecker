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
    _userMatchers = [[NSMutableArray alloc] init];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerTableViewCell];
    [self configureToolBar];

    RACSignal *userMatchersSignal = [[self.twittAppClient userMatchers] deliverOn:[RACScheduler mainThreadScheduler]];
    [self configureLabelsSignal:userMatchersSignal];
    [self configureTableView:userMatchersSignal];
}

    - (void)registerTableViewCell {
        UINib *nib = [UINib nibWithNibName:@"XIGTwitterUserCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        self.tableView.rowHeight = [XIGTwitterUserCell rowHeight];
    }

    #pragma mark - ToolBar Config
    - (void)configureToolBar {
        UIBarButtonItem *twitterLoadingItem= [self createTwitterLoadingButtonItem];
        UIBarButtonItem *friendCountItem = [self createFriendCountItem];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *friendFoundCountItem = [self createFriendFoundCountItem];
        UIBarButtonItem *appNetLoadingItem= [self createAppNetLoadingItem];
        self.toolbarItems = @[twitterLoadingItem, friendCountItem, spaceItem, friendFoundCountItem, appNetLoadingItem];
    }

        - (UIBarButtonItem *)createTwitterLoadingButtonItem {
            UIBarButtonItem *twitterLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
            _twitterLoadingIndicator = (UIActivityIndicatorView*) twitterLoadingItem.customView;
            return twitterLoadingItem;
        }

        - (UIBarButtonItem *)createFriendCountItem {
            UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
            friendsCountLabel.backgroundColor = [UIColor clearColor];
            friendsCountLabel.textColor = [UIColor whiteColor];
            friendsCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
            _friendsCountLabel = friendsCountLabel;
            UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:friendsCountLabel];
            return item2;
        }

        - (UIBarButtonItem *)createFriendFoundCountItem {
            UILabel *friendsFoundCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.toolbar.frame))];
            friendsFoundCountLabel.backgroundColor = [UIColor clearColor];
            friendsFoundCountLabel.textColor = [UIColor whiteColor];
            friendsFoundCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
            _friendsFoundCountLabel = friendsFoundCountLabel;
            _friendsFoundCountLabel.textAlignment = NSTextAlignmentRight;
            UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithCustomView:friendsFoundCountLabel];
            return item4;
        }

        - (UIBarButtonItem *)createAppNetLoadingItem {
            UIBarButtonItem *appNetLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
            _appNetLoadingIndicator = (UIActivityIndicatorView*) appNetLoadingItem.customView;
            return appNetLoadingItem;
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


        @weakify(self);
        [appNetUserCount subscribeNext:^(NSNumber *count) {
            @strongify(self);
            self.friendsFoundCountLabel.text = [NSString localizedStringWithFormat:@"%@ found.", count];
        } completed:^{
            @strongify(self);
            [self.appNetLoadingIndicator stopAnimating];
        }];
    }


    #pragma mark - User Matchers Insertion
    - (void)configureTableView:(RACSignal *)userMatchersSignal {
        [self configureUserMatchersNext:userMatchersSignal];
        [self configureUserMatchersCompletion:userMatchersSignal];
        [self configureUserMatchersError:userMatchersSignal];
    }

        - (void)configureUserMatchersNext:(RACSignal *)userMatchersSignal {
            @weakify(self);
            [userMatchersSignal subscribeNext:^(NSArray *matchersToAdd) {
                @strongify(self);
                NSRange insertionRange = [self insertUserMatchersInDataSource:matchersToAdd];
                [self insertNewRowsInTableView:insertionRange];
            }];
        }

            - (NSRange)insertUserMatchersInDataSource:(NSArray *)matchersToAdd {
                NSRange insertionRange = NSMakeRange(self.userMatchers.count, matchersToAdd.count);
                NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:insertionRange];

                [self insertUserMatchers:matchersToAdd atIndexes:insertionIndexes];//use this to trigger KVO notifications
                return insertionRange;
            }

            - (void)insertNewRowsInTableView:(NSRange)insertionRange{
                NSArray *insertedIndexPaths = [NSIndexPath indexPathsInSection:0 range:insertionRange];
                [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }


        - (void)configureUserMatchersCompletion:(RACSignal *)userMatchersSignal {
            @weakify(self);
            [userMatchersSignal subscribeCompleted:^{
                @strongify(self);
                [self.twitterLoadingIndicator stopAnimating];
                NSArray *newToolBarItems = [self.toolbarItems mtl_arrayByRemovingFirstObject]; // remove the loading indicator
                [self setToolbarItems:newToolBarItems animated:YES];
            }];
        }

        - (void)configureUserMatchersError:(RACSignal *)userMatchersSignal {

        }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userMatchers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XIGTwitterUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    XIGUserMatcher* userMatcher = self.userMatchers[indexPath.row];
    [cell bindUserMatcher:userMatcher];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
