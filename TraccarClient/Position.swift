//
// Copyright 2015 - 2017 Anton Tananaev (anton@traccar.org)
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
import CoreData
import CoreLocation

public class Position: NSManagedObject {
    
    @NSManaged public var deviceId: String?
    @NSManaged public var time: NSDate?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var altitude: NSNumber?
    @NSManaged public var speed: NSNumber?
    @NSManaged public var course: NSNumber?
    @NSManaged public var battery: NSNumber?
    @NSManaged public var charging: Bool
    @NSManaged public var accuracy: NSNumber?
    
    public convenience init(managedObjectContext context: NSManagedObjectContext) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Position", in: context)
        self.init(entity: entityDescription!, insertInto: context)
    }
    
    public func setLocation(_ location: CLLocation) {
        time = location.timestamp as NSDate
        latitude = location.coordinate.latitude as NSNumber
        longitude = location.coordinate.longitude as NSNumber
        altitude = location.altitude as NSNumber
        if location.speed >= 0 {
            speed = location.speed * 1.94384 as NSNumber // knots from m/s
        }
        if location.course >= 0 {
            course = location.course as NSNumber
        }
        accuracy = location.horizontalAccuracy as NSNumber
    }

}
