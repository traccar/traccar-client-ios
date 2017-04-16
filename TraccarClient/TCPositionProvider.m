//
// Copyright 2015 - 2017 Anton Tananaev (anton.tananaev@gmail.com)
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

#import "TCPositionProvider.h"
#import <CoreLocation/CoreLocation.h>
#import "TCDatabaseHelper.h"
#import "TCDistanceCalculator.h"

@interface TCPositionProvider () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, assign) long interval;
@property (nonatomic, assign) long distance;
@property (nonatomic, assign) long angle;

@end

@implementation TCPositionProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

        if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            self.locationManager.allowsBackgroundLocationUpdates = YES;
        }

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.deviceId = [userDefaults stringForKey:@"device_id_preference"];
        self.interval = [userDefaults integerForKey:@"frequency_preference"];
        self.distance = [userDefaults integerForKey:@"distance_preference"];
        self.angle = [userDefaults integerForKey:@"angle_preference"];
    }
    return self;
}

- (void)startUpdates {
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdates {
    [self.locationManager stopUpdatingLocation];
}

- (double)getBatteryLevel {
    UIDevice *device = [UIDevice currentDevice];
    if (device.batteryState != UIDeviceBatteryStateUnknown) {
        return device.batteryLevel * 100;
    } else {
        return 0;
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    CLLocation *location = [locations lastObject];
    
    if (!self.lastLocation
            || [location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] >= self.interval
            || (self.distance > 0 && [TCDistanceCalculator distanceFromLat:location.coordinate.latitude fromLon:location.coordinate.longitude toLat:self.lastLocation.coordinate.latitude toLon:self.lastLocation.coordinate.longitude] >= self.distance)
            || (self.angle > 0 && fabs(location.course - self.lastLocation.course) >= self.angle)) {
        
        TCPosition *position = [[TCPosition alloc] initWithManagedObjectContext:[TCDatabaseHelper managedObjectContext]];
        position.deviceId = self.deviceId;
        position.location = location;
        position.battery = [self getBatteryLevel];
        
        [self.delegate didUpdatePosition:position];
        self.lastLocation = location;
    }
}

@end
