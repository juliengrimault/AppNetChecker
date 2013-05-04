//
//  XIGUserFilterViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 21/4/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGUserFilterViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "XIGSemiModalController.h"
#import "CAKeyframeAnimation+XIGBouncing.h"

@interface XIGUserFilterViewController () {
    IBOutlet UILabel *_friendCountLabel;
    IBOutlet UILabel *_friendFoundCountLabel;
}

@property (nonatomic) XIGUserFilter currentFilter;
@property (nonatomic, strong) RACSignal *selectedFilter;
@end

@implementation XIGUserFilterViewController

#pragma mark - Initialization
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _currentFilter = XIGUserFilterAll;
    _selectedFilter = RACAbleWithStart(self.currentFilter);
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {

    RAC(_friendCountLabel,text) = [RACAbleWithStart(self.friendCount) map:^id(NSNumber *n) {
        return [NSString localizedStringWithFormat:@"%@ friends", n];
    }];

    RAC(_friendFoundCountLabel,text) = [RACAbleWithStart(self.friendFoundCount) map:^id(NSNumber *n) {
        return [NSString localizedStringWithFormat:@"%@ found", n];
    }];
}

- (IBAction)bounceButtonHandler:(id)sender
{
    [self.semiModalController setOpen:![self.semiModalController isOpen] animated:YES];
}


- (IBAction)selectAllHandler:(id)sender {
    self.currentFilter = XIGUserFilterAll;
}

- (IBAction)selectFoundHandler:(id)sender {
    self.currentFilter = XIGUserFilterFound;
}

- (IBAction)selectNotFoundHandler:(id)sender {
    self.currentFilter = XIGUserFilterNotFound;
}


@end
