//
// Copyright 2017 Anton Tananaev (anton@traccar.org)
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

import Foundation

class DistanceCalculator: NSObject {
    
    static let EQUATORIAL_EARTH_RADIUS = 6378.1370
    static let DEG_TO_RAD = Double.pi / 180
    
    static func distance(fromLat lat1: Double, fromLon lon1: Double, toLat lat2: Double, toLon lon2: Double) -> Double {
        let dlong = (lon2 - lon1) * DEG_TO_RAD
        let dlat = (lat2 - lat1) * DEG_TO_RAD
        let a = pow(sin(dlat / 2), 2) + cos(lat1 * DEG_TO_RAD) * cos(lat2 * DEG_TO_RAD) * pow(sin(dlong / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = EQUATORIAL_EARTH_RADIUS * c
        return d * 1000
    }

}
