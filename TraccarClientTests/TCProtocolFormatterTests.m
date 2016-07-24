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

#import "TCCoreDataTests.h"
#import "TCProtocolFormatter.h"

@interface TCProtocolFormatterTests : TCCoreDataTests

@end

@implementation TCProtocolFormatterTests

- (void)testFormatPosition {
    
    TCPosition *position = [[TCPosition alloc] initWithManagedObjectContext:self.managedObjectContext];
    position.deviceId = @"123456789012345";
    position.time = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSURL *url = [TCProtocolFormatter formatPostion:position address:@"localhost" port:5055 secure:NO];
    
    XCTAssertEqualObjects(@"http://localhost:5055?id=123456789012345&timestamp=0&lat=0.000000&lon=0.000000&speed=0&bearing=0&altitude=0&batt=0", url.absoluteString);
}

@end
