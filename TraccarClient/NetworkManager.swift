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
import SystemConfiguration

protocol NetworkManagerDelegate: AnyObject {
    func didUpdateNetwork(online: Bool)
}

class NetworkManager : NSObject {
    
    weak var delegate: NetworkManagerDelegate?
    
    //var reachability: SCNetworkReachability
    
    override init() {
        /*var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })!*/

        super.init()
    }

    func online() -> Bool {
        /*var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(reachability, &flags)
        return NetworkManager.online(for: flags)*/
        return true
    }
    
    func start() {
        /*var context = SCNetworkReachabilityContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, pointer) in
            let networkManager = Unmanaged<NetworkManager>.fromOpaque(pointer!).takeUnretainedValue()
            networkManager.delegate?.didUpdateNetwork(online: NetworkManager.online(for: flags))
        }, &context)
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)*/
    }
    
    func stop() {
        /*SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)*/
    }

    static func online(for flags: SCNetworkReachabilityFlags) -> Bool {
        if !flags.contains(.reachable) {
            return false
        }
        if !flags.contains(.connectionRequired) {
            return true
        }
        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
            if !flags.contains(.interventionRequired) {
                return true
            }
        }
        if flags.contains(.isWWAN) {
            return true
        }
        return false
    }

}
