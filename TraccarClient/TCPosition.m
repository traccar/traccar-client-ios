//
// Copyright 2015 Anton Tananaev (anton.tananaev@gmail.com)
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

#import "TCPosition.h"

@implementation TCPosition

@dynamic deviceId;
@dynamic time;
@dynamic latitude;
@dynamic longitude;
@dynamic altitude;
@dynamic speed;
@dynamic course;
@dynamic battery;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:context];
    return [self initWithEntity:entityDescription insertIntoManagedObjectContext:context];
}

- (void)setLocation:(CLLocation *)location {
    self.time = location.timestamp;
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    self.altitude = location.altitude;
    if (location.speed >= 0) {
        self.speed = location.speed * 1.94384; // knots from m/s
    }
    if (location.course >= 0) {
        self.course = location.course;
    }
}

@end
