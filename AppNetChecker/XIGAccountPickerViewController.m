//
//  JGAAccountPickerViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAccountPickerViewController.h"
#import <libextobjc/EXTScope.h>
#import <libextobjc/EXTKeyPathCoding.h>
#import "UIViewController+SLServiceHack.h"
#import "XIGAccountErrorCell.h"
#import "XIGTwitterUsersTableViewController.h"
#import "XIGTwitterClient.h"

@interface XIGAccountPickerViewController ()
@property (nonatomic, copy) NSArray* accounts;
@end

@implementation XIGAccountPickerViewController
- (XIGTwitterAccountStore*)reactiveTwitter
{
    if(!_reactiveTwitter) {
        _reactiveTwitter = [[XIGTwitterAccountStore alloc] init];
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
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self retrieveTwitterAccounts];
    [self bindUIToError];
}

- (void)retrieveTwitterAccounts
{
    [self.refreshControl beginRefreshing];
    @weakify(self);
    [[[self.reactiveTwitter twitterAccounts]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext: ^(NSArray* accounts) {
         @strongify(self);
         [self.refreshControl endRefreshing];
         self.accounts = accounts;
     }
     error: ^(NSError *error) {
         @strongify(self);
         [self.refreshControl endRefreshing];
         self.error = error;
     }];
}

- (void)bindUIToError
{
    @weakify(self)
    [RACAble(self.error) subscribeNext:^(id error) {
        @strongify(self);
        [self.tableView reloadData];
        [self showHelpForError:error];
    }];
}

- (void)showHelpForError:(NSError*)error
{
    if ([error.domain isEqualToString:ACErrorDomain] && error.code == ACErrorAccountNotFound) {
        [self presentRegisterServiceViewControllerWithServiceType:SLServiceTypeTwitter];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.error != nil) {
        return 1;
    } else {
        return self.accounts.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.error) {
        XIGAccountErrorCell* cell = (XIGAccountErrorCell*)[tableView dequeueReusableCellWithIdentifier:@"XIGAccountErrorCell"];
        [cell bindError:self.error];
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        ACAccount* account = self.accounts[indexPath.row];
        cell.textLabel.text = account.username;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.error) {
        return [XIGAccountErrorCell rowHeight];
    }
    return 44.0f;
}

#pragma mark - Retry
- (void)refreshControlValueChanged:(UIRefreshControl*)sender
{
    self.error = nil;
    [self retrieveTwitterAccounts];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushUsersTableViewController"]) {
        XIGTwitterUsersTableViewController* vc = segue.destinationViewController;
        
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
        if (selectedIndexPath) {
            ACAccount* selectedAccount = self.accounts[selectedIndexPath.row];
            vc.twitterClient = [XIGTwitterClient sharedClient];
            vc.twitterClient.account = selectedAccount;
        }
    }
}

@end
