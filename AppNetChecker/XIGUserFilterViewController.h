//
//  XIGUserFilterViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 21/4/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSUInteger , XIGUserFilter) {
    XIGUserFilterAll = 0,
    XIGUserFilterFound,
    XIGUserFilterNotFound
};

@interface XIGUserFilterViewController : UIViewController

@property (nonatomic) NSInteger friendCount;
@property (nonatomic) NSInteger friendFoundCount;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong, readonly) RACSignal *selectedFilter;
@end
