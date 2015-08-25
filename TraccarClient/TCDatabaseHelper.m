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

#import "TCDatabaseHelper.h"
#import <sqlite3.h>

NSString* const kDatabaseFile = @"traccar.db";

@interface TCDatabaseHelper ()

@property (nonatomic) sqlite3 *db;

@end

@implementation TCDatabaseHelper

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *file = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDatabaseFile];
        
        BOOL newDatabase = [[NSFileManager defaultManager] fileExistsAtPath:file];
        
        sqlite3_open([file UTF8String], &_db);
        
        if (newDatabase) {
            // TODO: init database
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(self.db);
}

@end
