//
//  VehicleTrackerViewModel.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2024/11/11.
//  Copyright © 2024 Traccar. All rights reserved.
//

import Foundation

struct VehicleTrackerViewModel {
    
    var connectionText: String {
        clockIn ? "● Connected" : "Disconnected"
    }
    var clockIn = false
    var clockInOrOut: String {
        clockIn ? " Clock out" : " Clock in"
    }
    
    var deviceIdentifier = "JXM 266 GP" // TODO: fetch from the back-end
    
    var repository = VehicleTrackerRepository()
    
    var serverURL: String? {
        UserDefaults.standard.string(forKey: "server_url_preference")!
    }
    
    var locationAccuracy: String? {
        UserDefaults.standard.string(forKey: "accuracy_preference")
    }
    
    func loginUser() {
//        repository.login()
        repository.getDevices()
    }
}
