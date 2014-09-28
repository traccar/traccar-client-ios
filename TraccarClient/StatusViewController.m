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

#import "StatusViewController.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

static int const LIMIT = 20;
static StatusViewController *statusViewController;

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

    NSMutableArray *messages = [StatusViewController getMessages];
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
    [[StatusViewController getMessages] removeAllObjects];
    
    if (statusViewController != nil) {
        [statusViewController.tableView reloadData];
    }
}

- (IBAction)clear:(UIBarButtonItem *)sender {
    [StatusViewController clearMessages];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[StatusViewController getMessages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"status";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = [[StatusViewController getMessages] objectAtIndex:indexPath.row];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
