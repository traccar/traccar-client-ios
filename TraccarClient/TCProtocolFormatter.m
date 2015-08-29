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

#import "TCProtocolFormatter.h"

@implementation TCProtocolFormatter

+ (NSURL *)formatPostion:(TCPosition *)position address:(NSString *)address port:(long)port {
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = @"http";
    components.percentEncodedHost = [NSString stringWithFormat:@"%@:%ld", address, port];
    
    NSMutableArray *queryItems = [[NSMutableArray alloc] init];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"id" value:position.deviceId]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"timestamp" value:[NSString stringWithFormat:@"%ld", (long) [position.time timeIntervalSince1970]]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lat" value:[NSString stringWithFormat:@"%g", position.latitude]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lon" value:[NSString stringWithFormat:@"%g", position.longitude]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"speed" value:[NSString stringWithFormat:@"%g", position.speed]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"bearing" value:[NSString stringWithFormat:@"%g", position.course]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"altitude" value:[NSString stringWithFormat:@"%g", position.altitude]]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"batt" value:[NSString stringWithFormat:@"%g", position.battery]]];
    components.queryItems = queryItems;
    
    return components.URL;
}

@end
