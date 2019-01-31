//
// Copyright 2013 - 2017 Anton Tananaev (anton.tananaev@gmail.com)
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
import CoreLocation

class TrackingController: NSObject, PositionProviderDelegate, NetworkManagerDelegate, CLLocationManagerDelegate {
    
    static let RETRY_DELAY: UInt64 = 30 * 1000;
    
    var online = false
    var waiting = false
    var stopped = false

    var positionProvider = PositionProvider()
    var locationManager = CLLocationManager()
    var databaseHelper = DatabaseHelper()
    var networkManager = NetworkManager()
    var userDefaults = UserDefaults.standard

    var url: String
    
    override init() {
        online = networkManager.online()
        url = userDefaults.string(forKey: "server_url_preference")!

        super.init()

        positionProvider.delegate = self
        locationManager.delegate = self
        networkManager.delegate = self
    }
    
    func start() {
        self.stopped = false
        if self.online {
            read()
        }
        positionProvider.startUpdates()
        locationManager.startMonitoringSignificantLocationChanges()
        networkManager.start()
    }
    
    func stop() {
        networkManager.stop()
        locationManager.stopMonitoringSignificantLocationChanges()
        positionProvider.stopUpdates()
        self.stopped = true
    }

    func didUpdate(position: Position) {
        StatusViewController.addMessage(NSLocalizedString("Location update", comment: ""))
        write(position)
    }
    
    func didUpdateNetwork(online: Bool) {
        StatusViewController.addMessage(NSLocalizedString("Connectivity change", comment: ""))
        if !self.online && online {
            read()
        }
        self.online = online
    }
    
    //
    // State transition examples:
    //
    // write -> read -> send -> delete -> read
    //
    // read -> send -> retry -> read -> send
    //
    
    func write(_ position: Position) {
        let context = DatabaseHelper().managedObjectContext
        if context.hasChanges {
            try? context.save()
        }
        if self.online && self.waiting {
            read()
            self.waiting = false
        }
    }
    
    func read() {
        if let position = databaseHelper.selectPosition() {
            if (position.deviceId == userDefaults.string(forKey: "device_id_preference")) {
                send(position)
            } else {
                delete(position)
            }
        } else {
            self.waiting = true
        }
    }
    
    func delete(_ position: Position) {
        databaseHelper.delete(position: position)
        read()
    }
    
    func send(_ position: Position) {
        if let request = ProtocolFormatter.formatPostion(position, url: url) {
            RequestManager.sendRequest(request, completionHandler: {(_ success: Bool) -> Void in
                if success {
                    self.delete(position)
                } else {
                    StatusViewController.addMessage(NSLocalizedString("Send failed", comment: ""))
                    self.retry()
                }
            })
        } else {
            StatusViewController.addMessage(NSLocalizedString("Send failed", comment: ""))
            self.retry()
        }
    }
    
    func retry() {
        let deadline = DispatchTime.now() + Double(TrackingController.RETRY_DELAY * NSEC_PER_MSEC) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: deadline, execute: {() -> Void in
            if !self.stopped && self.online {
                self.read()
            }
        })
    }

}
