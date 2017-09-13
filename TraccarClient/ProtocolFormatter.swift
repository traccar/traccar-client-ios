//
// Copyright 2016 - 2017 Anton Tananaev (anton.tananaev@gmail.com)
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

public class ProtocolFormatter: NSObject {
    
    public static func formatPostion(_ position: Position, url: String) -> URL {
        var components = URLComponents(string: url)

        var query = String()
        query += "id=\(position.deviceId!)&"
        query += "timestamp=\(Int(position.time!.timeIntervalSince1970))&"
        query += String(format: "lat=%.06f&", position.latitude!)
        query += String(format: "lon=%.06f&", position.longitude!)
        query += "speed=\(position.speed!)&"
        query += "bearing=\(position.course!)&"
        query += "altitude=\(position.altitude!)&"
        query += "batt=\(position.battery!)"
        components?.query = query

        // use queryItems for iOS 8
        return (components?.url)!
    }

}
