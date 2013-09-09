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
    self.sections = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
    
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
        NSArray *arr = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [arr count]; i++)
        {
            ABRecordRef ref = CFArrayGetValueAtIndex((__bridge CFArrayRef)(arr), i);
            
            CFStringRef firstName, lastName;
            
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
            
            [contact setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
            
            ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
            NSString *phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, 0);
            
            [contact setObject:(phone == nil ? @"" : phone) forKey:@"phone"];
            
            NSData *imgData = (__bridge NSData*)ABPersonCopyImageDataWithFormat((__bridge ABRecordRef)(arr[i]), kABPersonImageFormatThumbnail);
            UIImage *userImage = [UIImage imageWithData:imgData];
            
            if (userImage != nil) {
                [contact setObject:userImage forKey:@"image"];
            }
            else
            {
                [contact setObject:[UIImage imageNamed:@"Icon.png"] forKey:@"image"];
            }
            
            [newArr addObject:contact];
        }
        [newArr sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];

        self.contactList = newArr;
    }
    
    NSLog(@"%@", self.contactList);
    [self.tableView reloadData];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self.contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", [self.sections objectAtIndex:section]]];
    return  [sectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray *sectionArray = [self.contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", self.sections[indexPath.section]]];
    
    cell.textLabel.text = [sectionArray[indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [sectionArray[indexPath.row] objectForKey:@"phone"];
    cell.imageView.image = [sectionArray[indexPath.row] objectForKey:@"image"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionArray = [self.contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", self.sections[indexPath.section]]];

    NSString *phone = [sectionArray[indexPath.row] objectForKey:@"phone"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 27;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sections objectAtIndex:section];
}

@end
