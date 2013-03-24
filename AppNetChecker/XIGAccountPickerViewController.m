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
#import "XIGTwitterAccountCell.h"
#import "XIGSemiModalController.h"
#import "XIGAppNetClient.h"
#import "XIGTwitAppClient.h"

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

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self retrieveTwitterAccounts];
    [self bindUIToError];

    self.semiModalController.navigationItem.title = NSLocalizedString(@"TwitApp.net", nil);
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton.png"]
                                                             style:UIBarButtonItemStylePlain target:nil action:nil];
    back.title = @"a";
    self.semiModalController.navigationItem.backBarButtonItem = back;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
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
        XIGTwitterAccountCell *cell = (XIGTwitterAccountCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        ACAccount* account = self.accounts[indexPath.row];
        [cell bindAccont:account];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.error) {
        return [XIGAccountErrorCell rowHeight];
    }
    return [XIGTwitterAccountCell rowHeight];
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
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];

        XIGTwitterClient *twitterClient = [XIGTwitterClient sharedClient];
        XIGAppNetClient *appNetClient = [XIGAppNetClient sharedClient];
        if (selectedIndexPath) {
            ACAccount* selectedAccount = self.accounts[selectedIndexPath.row];
            twitterClient.account = selectedAccount;
        }
        XIGTwitAppClient *client = [[XIGTwitAppClient alloc] initWithTwitterClient:twitterClient appNetClient:appNetClient];
        vc.twittAppClient = client;
    }
}

@end
