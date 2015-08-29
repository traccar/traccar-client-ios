//
// Copyright 2014 Anton Tananaev (anton.tananaev@gmail.com)
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

#import "TCStatusViewController.h"

@implementation TCStatusViewController

static int const LIMIT = 20;
static TCStatusViewController *statusViewController;

+ (NSMutableArray *)getMessages
{
    static NSMutableArray *messages;
    
    if (messages == nil) {
        messages = [[NSMutableArray alloc] init];
    }

    return messages;
}

+ (void)addMessage:(NSString *)message
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm - "];

    NSMutableArray *messages = [TCStatusViewController getMessages];
    [messages addObject:[[formatter stringFromDate:[NSDate date]] stringByAppendingString:message]];
    
    if ([messages count] > LIMIT) {
        [messages removeObjectAtIndex:0];
    }
    
    if (statusViewController != nil) {
        [statusViewController.tableView reloadData];
    }
}

+ (void)clearMessages
{
    [[TCStatusViewController getMessages] removeAllObjects];
    
    if (statusViewController != nil) {
        [statusViewController.tableView reloadData];
    }
}

- (IBAction)clear:(UIBarButtonItem *)sender {
    [TCStatusViewController clearMessages];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    statusViewController = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    statusViewController = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[TCStatusViewController getMessages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"status";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[TCStatusViewController getMessages] objectAtIndex:indexPath.row];
    return cell;
}

@end
