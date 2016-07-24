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

#import "TCTrackingController.h"
#import "TCPositionProvider.h"
#import "TCDatabaseHelper.h"
#import "TCNetworkManager.h"
#import "TCProtocolFormatter.h"
#import "TCRequestManager.h"
#import "TCStatusViewController.h"

int64_t kRetryDelay = 30 * 1000;

@interface TCTrackingController () <TCPositionProviderDelegate, TCNetworkManagerDelegate>

@property (nonatomic) BOOL online;
@property (nonatomic) BOOL waiting;
@property (nonatomic) BOOL stopped;

@property (nonatomic, strong) TCPositionProvider *positionProvider;
@property (nonatomic, strong) TCDatabaseHelper *databaseHelper;
@property (nonatomic, strong) TCNetworkManager *networkManager;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) long port;
@property (nonatomic, assign) BOOL secure;

- (void)write:(TCPosition *)position;
- (void)read;
- (void)delete:(TCPosition *)position;
- (void)send:(TCPosition *)position;
- (void)retry;

@end

@implementation TCTrackingController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.positionProvider = [[TCPositionProvider alloc] init];
        self.databaseHelper = [[TCDatabaseHelper alloc] init];
        self.networkManager = [[TCNetworkManager alloc] init];
        
        self.positionProvider.delegate = self;
        self.networkManager.delegate = self;
        
        self.online = self.networkManager.online;
        
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.address = [self.userDefaults stringForKey:@"server_address_preference"];
        self.port = [self.userDefaults integerForKey:@"server_port_preference"];
        self.secure = [self.userDefaults integerForKey:@"secure_preference"];
    }
    return self;
}

- (void)start {
    self.stopped = NO;
    if (self.online) {
        [self read];
    }
    [self.positionProvider startUpdates];
    [self.networkManager start];
}

- (void)stop {
    [self.networkManager stop];
    [self.positionProvider stopUpdates];
    self.stopped = YES;
}

- (void)didUpdatePosition:(TCPosition *)position {
    [TCStatusViewController addMessage:NSLocalizedString(@"Location update", @"")];
    [self write:position];
}

- (void)didUpdateNetwork:(BOOL)online {
    [TCStatusViewController addMessage:NSLocalizedString(@"Connectivity change", @"")];
    if (!self.online && online) {
        [self read];
    }
    self.online = online;
}

//
// State transition examples:
//
// write -> read -> send -> delete -> read
//
// read -> send -> retry -> read -> send
//

- (void)write:(TCPosition *)position {
    if (self.online && self.waiting) {
        [self read];
        self.waiting = NO;
    }
}

- (void)read {
    TCPosition *position = [self.databaseHelper selectPosition];
    if (position) {
        if ([position.deviceId isEqualToString:[self.userDefaults stringForKey:@"device_id_preference"]]) {
            [self send:position];
        } else {
            [self delete:position];
        }
    } else {
        self.waiting = YES;
    }
}

- (void)delete:(TCPosition *)position {
    [self.databaseHelper deletePosition:position];
    [self read];
}

- (void)send:(TCPosition *)position {
    NSURL *request = [TCProtocolFormatter formatPostion:position address:self.address port:self.port secure:self.secure];
    [TCRequestManager sendRequest:request completionHandler:^(BOOL success) {
        if (success) {
            [self delete:position];
        } else {
            [TCStatusViewController addMessage:NSLocalizedString(@"Send failed", @"")];
            [self retry];
        }
    }];
}

- (void)retry {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRetryDelay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if (!self.stopped && self.online) {
            [self read];
        }
    });
}

@end
