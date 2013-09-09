//
//  ContactsViewController.h
//  iContact
//
//  Created by Ivelin Ivanov on 9/9/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *contactList;
@property (strong, nonatomic) NSArray *sections;

@end
