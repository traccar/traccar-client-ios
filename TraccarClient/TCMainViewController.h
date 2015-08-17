//
// Copyright 2013 - 2015 Anton Tananaev (anton.tananaev@gmail.com)
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

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IASKAppSettingsViewController.h"

@interface TCMainViewController : IASKAppSettingsViewController <CLLocationManagerDelegate, NSStreamDelegate>

@property (nonatomic) BOOL currentStatus;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, copy) NSString *deviceId, *address;
@property (nonatomic) long port, period;

@property (nonatomic) NSOutputStream *outputStream;

@property (nonatomic) NSDate *lastLocation;

- (void)defaultsChanged:(NSNotification *)notification;

- (void)openConnection;
- (void)closeConnection;

+ (NSString *)createIdentificationMessage:(NSString *)deviceId;
+ (NSString *)createLocationMessage:(CLLocation *)location;

@end
