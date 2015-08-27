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

#import "TCNetworkManager.h"
#import <arpa/inet.h>

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    TCNetworkManager *networkManager = (__bridge TCNetworkManager *)info;
    [networkManager.delegate didUpdateNetwork:[TCNetworkManager onlineForFlags:flags]];
}

@interface TCNetworkManager ()

@property (nonatomic, assign) SCNetworkReachabilityRef reachability;

@end

@implementation TCNetworkManager

- (instancetype)init {
    self = [super init];
    if (self) {
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        self.reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    }
    return self;
}

- (BOOL)online {
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.reachability, &flags);
    return [TCNetworkManager onlineForFlags:flags];
}

- (void)start {
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.reachability, ReachabilityCallback, &context)) {
        SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)stop {
    if (self.reachability != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

+ (BOOL)onlineForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return NO;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        return YES;
    }
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            return YES;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        return YES;
    }
    
    return NO;
}

@end
