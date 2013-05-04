//
//  XIGMultiViewControllerContainer.m
//  AppNetChecker
//
//  Created by Julien Grimault on 1/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGMultiViewControllerContainer.h"

@interface XIGMultiViewControllerContainer ()

@end

@implementation XIGMultiViewControllerContainer
#pragma mark - Properties
- (UIViewController *)selectedViewController
{
    if (self.viewControllers.count >= self.selectedIndex)
        return nil;
    
    return self.viewControllers[self.selectedIndex];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex == _selectedIndex) return;
    [self swapCurrentlySelectedVCWithVCAtIndex:selectedIndex];
}

    - (void)swapCurrentlySelectedVCWithVCAtIndex:(NSInteger)newIndex
    {
        UIViewController *currentlySelected = self.selectedViewController;
        if (currentlySelected != nil) {
            [currentlySelected willMoveToParentViewController:nil];
            [currentlySelected.view removeFromSuperview];
            [currentlySelected removeFromParentViewController];
        }
        
        _selectedIndex = newIndex;
        
        UIViewController *newlySelected = self.viewControllers[newIndex];
        [self addChildViewController:newlySelected];
        newlySelected.view.frame = self.view.bounds;
        [self.view addSubview:newlySelected.view];
        [newlySelected didMoveToParentViewController:self];
    }

#pragma mark - Init
- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        _viewControllers = viewControllers;
        _selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self swapCurrentlySelectedVCWithVCAtIndex:self.selectedIndex];
}
@end
