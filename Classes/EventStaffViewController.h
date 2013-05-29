//
//  EventStaffViewController.h
//  Hacker Dojo
//
//  Created by Jonathan Hull on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class Event;

@interface EventStaffViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (retain,nonatomic) Event *event;

@end