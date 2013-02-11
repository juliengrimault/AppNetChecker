//
//  JGAAccountPickerViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "JGAAccountPickerViewController.h"
#import <libextobjc/EXTScope.h>
#import <libextobjc/EXTKeyPathCoding.h>
#import "UIViewController+SLServiceHack.h"

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
    [self bindUIToError];
}

- (void)retrieveTwitterAccounts
{
    @weakify(self);
    [[[self.reactiveTwitter twitterAccount]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext: ^(NSArray* accounts) {
         @strongify(self);
         self.accounts = accounts;
     }
     error: ^(NSError *error) {
         @strongify(self);
         self.error = error;
     }];
}

- (void)bindUIToError
{
    @weakify(self)
    [RACAbleWithStart(self.error) subscribeNext:^(id error) {
        @strongify(self);
        self.errorLabel.hidden = (error == nil);
        self.retryButton.hidden = (error == nil);
        self.errorLabel.text = [self descriptionForError:error];
        [self showHelpForError:error];
    }];
}

- (NSString*)descriptionForError:(NSError*)error
{
    switch (error.code) {
        case ACErrorAccountNotFound:
            return NSLocalizedString(@"No Twitter account was found on your device.", nil);
            
        case ACErrorCodeAccessNotGranted:
            return NSLocalizedString(@"Enable Twitter access for App.NetChecker from your device's Settings > Twitter", nil);
            
        default:
            return NSLocalizedString(@"An error has occurred. Please try again later.", nil);
    }
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
    return self.accounts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    ACAccount* account = self.accounts[indexPath.row];
    cell.textLabel.text = account.username;
    return cell;
}

#pragma mark - Retry
- (IBAction)retryButtonHandler:(id)sender
{
    self.error = nil;
    [self retrieveTwitterAccounts];
}

@end
