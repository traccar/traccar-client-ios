//
//  ViewController.m
//  TraccarClient
//
//  Created by User on 7/09/13.
//  Copyright (c) 2013 Traccar. All rights reserved.
//

#import "ViewController.h"

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
            [self openConnection];
            
            // Start location updates
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            [locationManager startUpdatingLocation];
        }
        else
        {
            // Stop location updates
            [locationManager stopUpdatingLocation];
            locationManager = nil;
            
            [self closeConnection];
        }
        
        currentStatus = newStatus;
    }
}

- (void)openConnection
{
    // Establish network connection
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) address, port, NULL, &writeStream);
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
            components.hour, components.minute, components.second,
            (int) trunc(fabs(lat)), fmod(fabs(lat), 1.0) * 60.0, (lat > 0) ? @"N" : @"S",
            (int) trunc(fabs(lon)), fmod(fabs(lon), 1.0) * 60.0, (lon > 0) ? @"E" : @"W",
            (location.speed > 0) ? location.speed * 1.943844 : 0.0,
            (location.course > 0) ? location.course : 0.0,
            components.day, components.month, components.year % 100];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if (!lastLocation || [location.timestamp timeIntervalSinceDate:lastLocation] > period)
    {
        NSLog(@"Send location update");
        
        // Send location
        if (outputStream)
        {
            NSString *message = [ViewController createLocationMessage:location];
            [outputStream write:(const uint8_t *)[message UTF8String] maxLength:message.length];
        }
        
        lastLocation = location.timestamp;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (eventCode == NSStreamEventErrorOccurred)
    {
        NSLog(@"Network error: %@", [outputStream streamError]);
        
        // Reconnect
        [self closeConnection];
        [self openConnection];
    }
}

@end
