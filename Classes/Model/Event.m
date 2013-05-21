//
//  Event.m
//  Hacker Dojo Test
//
//  Created by Jonathan Hull on 12/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Event.h"



@implementation Event
@synthesize eventId,title,rooms,startTime, endTime,status,creator,eventType,size;
@synthesize details,cost,rsvp,staff;
@synthesize hasDetails;
@synthesize searchString;
@synthesize calendarEventId;

static EKEventStore *eventStore = nil;


- (id)init {
    if ((self = [super init])) {
        rsvp = eventRSVPNotAttending;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        self.eventId = [coder decodeIntegerForKey:@"eventId"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.startTime = [coder decodeObjectForKey:@"startTime"];
        self.endTime = [coder decodeObjectForKey:@"endTime"];
        self.rooms = [coder decodeObjectForKey:@"rooms"];
        self.status = [coder decodeObjectForKey:@"status"];
        self.creator = [coder decodeObjectForKey:@"creator"];
        self.creatorName = [coder decodeObjectForKey:@"creatorName"];
        self.eventType = [coder decodeObjectForKey:@"eventType"];
        self.size = [coder decodeIntegerForKey:@"size"];
        self.details = [coder decodeObjectForKey:@"details"];
        self.cost = [coder decodeObjectForKey:@"cost"];
        self.rsvp = [coder decodeIntegerForKey:@"rsvp"];
        self.staff = [coder decodeObjectForKey:@"staff"];
        self.hasDetails = [coder decodeBoolForKey:@"hasDetails"];
        self.searchString = [coder decodeObjectForKey:@"searchString"];
        self.calendarEventId = [coder decodeObjectForKey:@"calendarEventId"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger:self.eventId forKey:@"eventId"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.startTime forKey:@"startTime"];
    [coder encodeObject:self.endTime forKey:@"endTime"];
    [coder encodeObject:self.rooms forKey:@"rooms"];
    [coder encodeObject:self.status forKey:@"status"];
    [coder encodeObject:self.creator forKey:@"creator"];
    [coder encodeObject:self.creatorName forKey:@"creatorName"];
    [coder encodeObject:self.eventType forKey:@"eventType"];
    [coder encodeInteger:self.size forKey:@"size"];
    [coder encodeObject:self.details forKey:@"details"];
    [coder encodeObject:self.cost forKey:@"cost"];
    [coder encodeInteger:self.rsvp forKey:@"rsvp"];
    [coder encodeObject:self.staff forKey:@"staff"];
    [coder encodeBool:self.hasDetails forKey:@"hasDetails"];
    [coder encodeObject:self.searchString forKey:@"searchString"];
    [coder encodeObject:self.calendarEventId forKey:@"calendarEventId"];
}


- (void)dealloc {
    [title release];
    [startTime release];
    [endTime release];
    [rooms release];
    [status release];
    [creator release];
    [self.creatorName release];
    [eventType release];
    [details release];
    [cost release];
    [staff release];
    [searchString release];
    [calendarEventId release];
    [super dealloc];
}

-(void)calculateSearchString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"EEEE MMMM d HH"];
    
    //NSString *roomString = //@"";
    self.searchString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",title,[rooms componentsJoinedByString:@" "],[formatter stringFromDate:startTime],creator,eventType];
    [formatter release];
}

-(NSString*)roomString
{
    if([rooms count] == 9){
        return @"The Entire Dojo";
    }
    
    return [rooms componentsJoinedByString:@", "];
}

-(NSString*)shortRoomString
{
    if([rooms count] == 0){
        return @"TBD";
    }
    if([rooms count] == 9){
        return @"Full Dojo";
    }
    if([rooms count] == 1){
        NSString *theOneRoom = [rooms objectAtIndex:0];
        if([theOneRoom isEqualToString:@"Front Area"]){
            return @"Lobby";
        }
        if([theOneRoom isEqualToString:@"Upstairs Office"]){
            return @"Office";
        }
        if([theOneRoom isEqualToString:@"140b"]){
            return @"140 B";
        }
        return theOneRoom;
    }
    if([rooms count] == 2){
        //if([[rooms objectAtIndex:0]isEqualToString:@"Savanna"] && [[rooms objectAtIndex:1]isEqualToString:@"140b"]){
            //return @"B+Savanna";
        //}
        //if([[rooms objectAtIndex:0]isEqualToString:@"Cave"] && [[rooms objectAtIndex:1]isEqualToString:@"Deck"]){
        //    return @"Cave+Deck";
        //}
    }
    
    return @"Multiple";
}

-(NSString*)creatorName
{
    if (_creatorName == nil) {
        _creatorName = [self makeCreatorName];
    }
    return _creatorName;
}

-(NSString*)makeCreatorName
{
    NSArray *split = [self.creator componentsSeparatedByString:@"@"];
    if([split count]<=1){
        return self.creator;//Something is wrong, just return the creator
    }
    
    NSArray *nameArray = [[split objectAtIndex:0] componentsSeparatedByString:@"."];
    if([nameArray count]>1){
        return [NSString stringWithFormat:@"%@ %@",[[nameArray objectAtIndex:0]capitalizedString],[[nameArray objectAtIndex:1]capitalizedString]];
    }
    if([nameArray count]){
        return [[nameArray objectAtIndex:0]capitalizedString];
    }
    return self.creator;
}

-(NSString*)length
{
    if(endTime == nil){
        return nil;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:startTime toDate:endTime options:0];
    
    if([components hour] == 0){
        return [NSString stringWithFormat:@"%d min",[components minute]];
    }
    
    NSString *hourStr;
    if([components hour] > 1){
        hourStr = @"hours";
    }else{
        hourStr = @"hour";
    }
    
    if([components minute] == 0){
        return [NSString stringWithFormat:@"%d %@",[components hour],hourStr];
    }else{
        return [NSString stringWithFormat:@"%d %@ %d min",[components hour],hourStr,[components minute]];
    }
    
    
}

-(BOOL)isHappeningNow
{
    //return YES;
    //return ([startTime timeIntervalSinceNow] < 0);
    //return ([startTime timeIntervalSinceNow] < 0 && [endTime timeIntervalSinceNow] > 0);
    return ([startTime timeIntervalSinceNow] < 0 && [endTime timeIntervalSinceNow] > 0 && ![self isCancelled]);//is currently happening & not cancelled
}

-(BOOL)isCancelled
{
    return ([self.status isEqualToString:@"canceled"]);
}

/*
 The following method creates a new EKEvent, or if it has already been created, updates the event to match.
 */
-(BOOL)createMatchingCalendarEvent
{
    BOOL __block success = NO;
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    BOOL warned = [prefs boolForKey:@"warnedCalendarPrivacy"];
    //EKEventStore *eventStore = nil;
    if(eventStore == nil){
        eventStore = [[EKEventStore alloc]init];
        NSLog(@"EventStore:%@",eventStore);
    }
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [prefs setBool:NO forKey:@"warnedCalendarPrivacy"];
                success = [self createTheEvent];
            }
            else {
                if (!warned) {
                    NSString* msg = @"Enable calendar access in your privacy settings to enable adding events to your calendar";
                    NSString* alertTitle = @"Couldn't add event to your calendar";
                    [self displayNotificationAlert:alertTitle withMessage:msg];
                    [prefs setBool:YES forKey:@"warnedCalendarPrivacy"];
                }
                NSLog(@"Error: Hackdojo.app does not have permission to save events to the calendar");
            }
        }];
    }
    else
        success = [self createTheEvent];

    return success;
}

-(bool)createTheEvent
{
    EKEvent *calEvent = nil;
    if(self.calendarEventId){
        calEvent=[eventStore eventWithIdentifier:self.calendarEventId];
    }else{
        EKCalendar *cal = [eventStore defaultCalendarForNewEvents];
        calEvent = [EKEvent eventWithEventStore:eventStore];
        calEvent.calendar = cal;
    }
    calEvent.title = self.title;
    calEvent.startDate = self.startTime;
    calEvent.endDate = self.endTime;
    calEvent.location = [NSString stringWithFormat:@"Hacker Dojo - %@",[self roomString]];
    calEvent.notes = self.details;
    
    NSError *error = nil;
    BOOL success = [eventStore saveEvent:calEvent span:EKSpanThisEvent error:&error];
    
    if(success){
        self.calendarEventId = [calEvent eventIdentifier];
    }else{
        NSLog(@"ERROR - Writing Event: %@",[error localizedDescription]);
    }
    return success;
}

// Returns YES as long as calendarEventId can be guarenteed to be nil.
// Otherwise, returns NO.
-(BOOL)removeMatchingCelendarEvent
{
    BOOL __block retVal = YES;
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    BOOL warned = [prefs boolForKey:@"warnedCalendarPrivacy"];
    if(eventStore == nil){
        eventStore = [[EKEventStore alloc]init];
        NSLog(@"EventStore:%@",eventStore);
    }

    if(self.calendarEventId){
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    [prefs setBool:NO forKey:@"warnedCalendarPrivacy"];
                    retVal = [self removeTheEvent];
                }
                else {
                    // one time alert that: Enable calendar access in your privacy settings to enable adding events to your calendar
                    if (!warned) {
                        NSString* msg = @"Enable calendar access in your privacy settings to enable removing scheduled events from your calendar";
                        NSString* alertTitle = @"Couldn't remove the event from your calendar";
                        [self displayNotificationAlert:alertTitle withMessage:msg];
                        [prefs setBool:YES forKey:@"warnedCalendarPrivacy"];
                    }
                    NSLog(@"Error: Hackdojo.app does not have permission to remove events from the calendar");
                }
            }];
        }
        else
            retVal = [self removeTheEvent];
        
    }
    return retVal;
}

// Returns NO if deletion fails, otherwise returns YES
-(BOOL)removeTheEvent
{
    BOOL retVal = YES;
    EKEvent *calEvent=[eventStore eventWithIdentifier:self.calendarEventId];
    if(calEvent){
        NSError *error = nil;
        retVal = [eventStore removeEvent:calEvent span:EKSpanThisEvent error:&error];
        if (retVal)
            self.calendarEventId = nil;
    }
    else {
        NSLog(@"ERROR: calendarEvendId cannot be found in the calendar");
        self.calendarEventId = nil;     // Clean up the stale entry
    }
    return retVal;
}

-(void)displayNotificationAlert:(NSString*)alert withMessage:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:alert
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
