//
//  ContactsViewController.m
//  iContact
//
//  Created by Ivelin Ivanov on 9/9/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadContacts];
}

-(void)loadContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        accessGranted = YES;
    }
    
    if (accessGranted)
    {
        self.contactList = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    }
    
    NSLog(@"%@", self.contactList);
    [self.tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contactList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ABRecordRef ref = CFArrayGetValueAtIndex((__bridge CFArrayRef)(self.contactList), indexPath.row);
    
    CFStringRef firstName, lastName;
    
    firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);

    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
    NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, 0);
    cell.detailTextLabel.text = phone == nil ? @"" : phone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABRecordRef ref = CFArrayGetValueAtIndex((__bridge CFArrayRef)(self.contactList), indexPath.row);

    ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
    NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, 0);
    
    NSLog(@"%@", phone);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];

}


@end
