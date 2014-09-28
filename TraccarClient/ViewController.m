//
// Copyright 2013 - 2014 Anton Tananaev (anton.tananaev@gmail.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "ViewController.h"
#import "StatusViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize currentStatus;
@synthesize locationManager;
@synthesize deviceId, address;
@synthesize port, period;
@synthesize outputStream;
@synthesize lastLocation;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Traccar Client", @"");
    currentStatus = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [StatusViewController addMessage:@"Low memory warning"];
}

- (void)defaultsChanged:(NSNotification *)notification
{
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    
    // Update settings
    deviceId = [defaults stringForKey:@"device_id_preference"];
    address = [defaults stringForKey:@"server_address_preference"];
    port = [defaults integerForKey:@"server_port_preference"];
    period = [defaults integerForKey:@"frequency_preference"];
    
    // Check status
    BOOL newStatus = [defaults boolForKey:@"service_status_preference"];
    if (newStatus != currentStatus)
    {
        NSLog(@"Service status changed: %@", newStatus ? @"ON" : @"OFF");
        
        if (newStatus)
        {
            [StatusViewController addMessage:@"Service started"];
            
            [self openConnection];
            
            // Start location updates
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.pausesLocationUpdatesAutomatically = NO;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            [locationManager startUpdatingLocation];
        }
        else
        {
            // Stop location updates
            [locationManager stopUpdatingLocation];
            locationManager = nil;
            
            [self closeConnection];

            [StatusViewController addMessage:@"Service stopped"];
        }
        
        currentStatus = newStatus;
    }
}

- (void)openConnection
{
    // Establish network connection
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) address, (int) port, NULL, &writeStream);
    outputStream = (__bridge_transfer NSOutputStream *) writeStream;
    outputStream.delegate = self;
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream open];
    
    // Send identification
    NSString *message = [ViewController createIdentificationMessage:deviceId];
    [outputStream write:(const uint8_t *)[message UTF8String] maxLength:message.length];
}

- (void)closeConnection
{
    // Close network connection
    if (outputStream)
    {
        [outputStream close];
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        outputStream = nil;
    }
}

+ (NSString *)createIdentificationMessage:(NSString *)deviceId
{
    return [NSString stringWithFormat:@"$PGID,%@*00\r\n", deviceId];
}

+ (NSString *)createLocationMessage:(CLLocation *)location
{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    unitFlags |= NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [calendar components:unitFlags fromDate:location.timestamp];
    
    double lat = location.coordinate.latitude;
    double lon = location.coordinate.longitude;
    
    return [NSString stringWithFormat:@"$GPRMC,%02d%02d%02d.000,A,%02d%07.4f,%@,%03d%07.4f,%@,%.2f,%.2f,%02d%02d%02d,,*00\r\n",
            (int) components.hour, (int) components.minute, (int) components.second,
            (int) trunc(fabs(lat)), fmod(fabs(lat), 1.0) * 60.0, (lat > 0) ? @"N" : @"S",
            (int) trunc(fabs(lon)), fmod(fabs(lon), 1.0) * 60.0, (lon > 0) ? @"E" : @"W",
            (location.speed > 0) ? location.speed * 1.943844 : 0.0,
            (location.course > 0) ? location.course : 0.0,
            (int) components.day, (int) components.month, (int) components.year % 100];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if (!lastLocation || [location.timestamp timeIntervalSinceDate:lastLocation] > period)
    {
        NSLog(@"Send location update");
        [StatusViewController addMessage:@"Location update"];

        // Send location
        if (outputStream)
        {
            NSString *message = [ViewController createLocationMessage:location];
            [outputStream write:(const uint8_t *)[message UTF8String] maxLength:message.length];
        }
        
        lastLocation = location.timestamp;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location error: %@", [error localizedDescription]);
    [StatusViewController addMessage:@"Location error"];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"LocationManager: pause");
    [StatusViewController addMessage:@"LocationManager pause"];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"LocationManager: resume");
    [StatusViewController addMessage:@"LocationManager resume"];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"Event: NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"Event: NSStreamEventOpenCompleted");
            [StatusViewController addMessage:@"Connection succeeded"];
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"Event: NSStreamEventHasBytesAvailable");
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Event: NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"Event: NSStreamEventErrorOccurred");
            [StatusViewController addMessage:@"Network error"];
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Event: NSStreamEventEndEncountered");
            [StatusViewController addMessage:@"Connection closed"];
            break;
    }
    
    if (eventCode == NSStreamEventErrorOccurred || eventCode == NSStreamEventEndEncountered)
    {
        if (eventCode == NSStreamEventErrorOccurred)
        {
            NSLog(@"Network error: %@", [outputStream streamError]);
        }
        
        // Reconnect
        [self closeConnection];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self openConnection];
        });
    }
}

@end
