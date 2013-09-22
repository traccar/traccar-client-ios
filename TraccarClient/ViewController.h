//
//  ViewController.h
//  TraccarClient
//
//  Created by User on 7/09/13.
//  Copyright (c) 2013 Traccar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IASKAppSettingsViewController.h"

@interface ViewController : IASKAppSettingsViewController <CLLocationManagerDelegate, NSStreamDelegate>

@property (nonatomic) BOOL currentStatus;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, copy) NSString *deviceId, *address;
@property (nonatomic) int port, period;

@property (nonatomic) NSOutputStream *outputStream;

@property (nonatomic) NSDate *lastLocation;

- (void)defaultsChanged:(NSNotification *)notification;

- (void)openConnection;
- (void)closeConnection;

+ (NSString *)createIdentificationMessage:(NSString *)deviceId;
+ (NSString *)createLocationMessage:(CLLocation *)location;

@end
