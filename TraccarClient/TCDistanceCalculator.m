//
// Copyright 2017 Anton Tananaev (anton.tananaev@gmail.com)
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

#import "TCDistanceCalculator.h"

@implementation TCDistanceCalculator

static double const EQUATORIAL_EARTH_RADIUS = 6378.1370;
static double const DEG_TO_RAD = M_PI / 180;

+ (double)distanceFromLat:(double)lat1 fromLon:(double)lon1 toLat:(double)lat2 toLon:(double)lon2 {
    
    double dlong = (lon2 - lon1) * DEG_TO_RAD;
    double dlat = (lat2 - lat1) * DEG_TO_RAD;
    double a = pow(sin(dlat / 2), 2)
        + cos(lat1 * DEG_TO_RAD) * cos(lat2 * DEG_TO_RAD) * pow(sin(dlong / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = EQUATORIAL_EARTH_RADIUS * c;
    return d * 1000;
}

@end
