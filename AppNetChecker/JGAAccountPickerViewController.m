//
//  JGAAccountPickerViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "JGAAccountPickerViewController.h"
#import <libextobjc/EXTScope.h>

@interface JGAAccountPickerViewController ()
@property (nonatomic, copy) NSArray* accounts;
@end

@implementation JGAAccountPickerViewController
- (JGReactiveTwitter*)reactiveTwitter
{
    if(!_reactiveTwitter) {
        _reactiveTwitter = [[JGReactiveTwitter alloc] init];
    }
    return _reactiveTwitter;
}

- (void)setAccounts:(NSArray *)accounts
{
    if (accounts == _accounts) return;
    _accounts = [accounts copy];
    [self.tableView reloadData];
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrieveTwitterAccounts];
}

- (void)retrieveTwitterAccounts
{
    @weakify(self);
    [[[self.reactiveTwitter twitterAccountSignal]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext: ^(NSArray* accounts) {
         @strongify(self);
         self.accounts = accounts;
     }
     error: ^(NSError *error) {
         @strongify(self);
         self.errorLabel.hidden = NO;
         self.errorLabel.text = NSLocalizedString(@"No Twitter account was found on your device.", nil);
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)viewDidLayoutSubviews
{
    self.tableView.center = self.view.center;
    self.errorLabel.center = self.view.center;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accounts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    ACAccount* account = self.accounts[indexPath.row];
    cell.textLabel.text = account.username;
    return cell;
}

@end
