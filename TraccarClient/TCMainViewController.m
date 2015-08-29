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

#import "TCMainViewController.h"
#import "TCStatusViewController.h"
#import "TCTrackingController.h"

@interface TCMainViewController ()

@property (nonatomic, strong) TCTrackingController *trackingController;

- (void)defaultsChanged:(NSNotification *)notification;

@end

@implementation TCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Traccar Client", @"");
    self.showCreditsFooter = NO;
    self.neverShowPrivacySettings = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)defaultsChanged:(NSNotification *)notification
{
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    
    BOOL status = [defaults boolForKey:@"service_status_preference"];
    if (status && !self.trackingController) {

        [TCStatusViewController addMessage:NSLocalizedString(@"Service created", @"")];
        self.trackingController = [[TCTrackingController alloc] init];
        [self.trackingController start];

    } else if (!status && self.trackingController) {

        [TCStatusViewController addMessage:NSLocalizedString(@"Service destroyed", @"")];
        [self.trackingController stop];
        self.trackingController = nil;

    }
}

@end
