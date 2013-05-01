//
//  XIGSemiModalController+FriendsVC.m
//  AppNetChecker
//
//  Created by Julien Grimault on 1/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGSemiModalController+FriendsVC.h"
#import "XIGUserMatcherTableViewController.h"
#import "XIGMultiViewControllerContainer.h"
#import "XIGUserFilterViewController.h"
#import "XIGUserMatcher.h"
#import "RACSignal+AggregateReporting.h"

@implementation XIGSemiModalController (FriendsVC)

+ (instancetype)friendsVCWithUserMatcherSignal:(RACSignal *)signal
{
    XIGUserFilterViewController *filterVC = [[XIGUserFilterViewController alloc] init];
    XIGMultiViewControllerContainer *multiVC = [self multiVCWithSignal:signal];
    
    [self setupBindingBetweenFilter:filterVC andContainer:multiVC];
    XIGSemiModalController *semiModal = [[self alloc] initWithFrontViewController:filterVC backViewController:multiVC];
    semiModal.title = NSLocalizedString(@"Friends", nil);
    semiModal.open = YES;
    return semiModal;
}

+ (XIGMultiViewControllerContainer *)multiVCWithSignal:(RACSignal *)signal
{
    RACSignal *all = [signal setNameWithFormat:@"All"];
    
    RACSignal *foundSignal = [[signal filter:^BOOL(XIGUserMatcher *m) {
        return m.appNetUser != nil;
    }] setNameWithFormat:@"Found"];
    
    RACSignal *notFoundSignal = [[signal filter:^BOOL(XIGUserMatcher *m) {
        return m.appNetUser == nil;
    }] setNameWithFormat:@"NotFound"];
    
    NSArray *signals = @[all, foundSignal, notFoundSignal];
    NSArray *matchersTableVCs = [signals mtl_mapUsingBlock:^id(RACSignal *s) {
        return [[XIGUserMatcherTableViewController alloc] initWithUserMatchersSignal:s];
    }];
    
    XIGMultiViewControllerContainer *multiVC = [[XIGMultiViewControllerContainer alloc] initWithViewControllers:matchersTableVCs];
    return multiVC;
}

+ (void)setupBindingBetweenFilter:(XIGUserFilterViewController *)filterVC andContainer:(XIGMultiViewControllerContainer *)multiVC
{
    RAC(multiVC, selectedIndex) = filterVC.selectedFilter;
    
    NSArray *signals = [multiVC.viewControllers mtl_mapUsingBlock:^id(XIGUserMatcherTableViewController *vc) {
        return vc.userMatchersSignal;
    }];
    RACSignal *allUsers = signals[XIGUserFilterAll];
    RACSignal *foundUsers = signals[XIGUserFilterFound];
    
    RAC(filterVC, friendCount) = [[allUsers progressiveCount] setNameWithFormat:@"App.net All count"];
    RAC(filterVC, friendFoundCount) = [[foundUsers progressiveCount] setNameWithFormat:@"App.net NotFound Count"];
}
@end
