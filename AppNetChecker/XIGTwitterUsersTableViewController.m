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
#import "XIGTwitAppClient.h"
#import "RACSignal+AggregateReporting.h"
#import "XIGUserMatchersToolbar.h"
#import "UITableView+XIGBackgroundView.h"
#import "RACSignal+XIGBuffer.h"
#import "XIGSemiModalController.h"
#import "XIGUserFilterViewController.h"

static NSString * const CellIdentifier = @"TwitterUserCell";

@interface XIGTwitterUsersTableViewController ()
    @property (nonatomic, readonly) XIGUserFilterViewController *filterViewController;
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


- (XIGUserFilterViewController *)filterViewController {
    return (XIGUserFilterViewController *)self.semiModalController.frontViewController;
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
    self.title = NSLocalizedString(@"Friends", nil);
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];

    RACSignal *userMatchersSignal = [[[self.twittAppClient userMatchers] deliverOn:[RACScheduler mainThreadScheduler]] logAll];
    [self bindToolbarToSignal:userMatchersSignal];
    [self bindTableViewDataSourceToSignal:userMatchersSignal];
}

#pragma mark - UI Setup

    - (void)configureTableView {
        [self.tableView xig_configureBackgroundView];
        UINib *nib = [UINib nibWithNibName:@"XIGTwitterUserCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        self.tableView.rowHeight = [XIGTwitterUserCell rowHeight];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

#pragma mark - Toolbar Setup
    - (void)bindToolbarToSignal:(RACSignal *)userMatchersSignal {
        [self bindFriendCountLabel];
        RACSignal *matchersWithoutErrors = [userMatchersSignal catchTo:[RACSignal empty]];
        [self bindFriendFoundCountLabel:matchersWithoutErrors];
    }

        - (void)bindFriendCountLabel {
            RAC(self.filterViewController.friendCount) =[RACAbleWithStart(self.userMatchers) map:^id(NSArray *users) {
                return @(users.count);
            }];
        }

        - (void)bindFriendFoundCountLabel:(RACSignal *)userMatchersSignal {
            RACSignal *appNetUserCount= [[self foundFriendsCountSignal:userMatchersSignal] deliverOn:[RACScheduler mainThreadScheduler]];
            RAC(self.filterViewController.friendFoundCount) = appNetUserCount;

            @weakify(self);
            [appNetUserCount subscribeCompleted:^{
                @strongify(self);
                DDLogInfo(@"appNetUserCount completed - %d", self.filterViewController.friendFoundCount);
                [self.filterViewController.activityIndicator stopAnimating];
            }];
        }

            - (RACSignal *)foundFriendsCountSignal:(RACSignal *)userMatchersSignal {
                RACSignal *appNetUserCount = [[userMatchersSignal aggregateProgressWithStart:@0 combine:^id(NSNumber *current, XIGUserMatcher *u) {
                    NSUInteger count = [current unsignedIntegerValue];
                    if (u.appNetUser != nil) ++count;
                    return @(count);
                }] setNameWithFormat:@"App.net count"];
                return appNetUserCount;
            }


#pragma mark - Data Source Setup
    - (void)bindTableViewDataSourceToSignal:(RACSignal *)userMatchersSignal {
        RACSignal *bufferedMatchers = [[userMatchersSignal xig_buffer:2] map:^id(RACTuple *tuple) {
           return tuple.allObjects;
        }];

        [self configureUserMatchersNext:bufferedMatchers];
        [self configureUserMatchersError:bufferedMatchers];
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

            - (void)insertNewRowsInTableView:(NSRange)insertionRange {
                NSArray *insertedIndexPaths = [NSIndexPath indexPathsInSection:0 range:insertionRange];
                [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
            }

        - (void)configureUserMatchersError:(RACSignal *)userMatchersSignal {
            [userMatchersSignal subscribeError:^(NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Something Went Wrong...", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }];
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
