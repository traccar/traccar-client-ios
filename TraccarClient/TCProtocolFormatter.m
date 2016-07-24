//
// Copyright 2016 Anton Tananaev (anton.tananaev@gmail.com)
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

#import "TCProtocolFormatter.h"

@implementation TCProtocolFormatter

+ (NSURL *)formatPostion:(TCPosition *)position address:(NSString *)address port:(long)port secure:(BOOL)secure {
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = secure ? @"https" : @"http";
    components.percentEncodedHost = [NSString stringWithFormat:@"%@:%ld", address, port];
    
    NSMutableString *query = [[NSMutableString alloc] init];
    [query appendFormat:@"id=%@&", position.deviceId];
    [query appendFormat:@"timestamp=%ld&", (long) [position.time timeIntervalSince1970]];
    [query appendFormat:@"lat=%.06f&", position.latitude];
    [query appendFormat:@"lon=%.06f&", position.longitude];
    [query appendFormat:@"speed=%g&", position.speed];
    [query appendFormat:@"bearing=%g&", position.course];
    [query appendFormat:@"altitude=%g&", position.altitude];
    [query appendFormat:@"batt=%g", position.battery];
    components.query = query; // use queryItems for iOS 8
    
    return components.URL;
}

@end
