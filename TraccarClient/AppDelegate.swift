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

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var managedObjectContext: NSManagedObjectContext?
    var managedObjectModel: NSManagedObjectModel?
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    static var trackingController: TrackingController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        #if FIREBASE
        FirebaseApp.configure()
        #endif

        UIDevice.current.isBatteryMonitoringEnabled = true

        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "device_id_preference") == nil {
            srandomdev()
            let identifier = "\(arc4random_uniform(900000) + 100000)"
            userDefaults.setValue(identifier, forKey: "device_id_preference")
        }

        registerDefaultsFromSettingsBundle()
        
        migrateLegacyDefaults()
        
        let modelUrl = Bundle.main.url(forResource: "TraccarClient", withExtension: "momd")
        managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl!)
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("TraccarClient.sqlite")
        try! persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(nil, forKey: "service_status_preference")
        
        if let context = managedObjectContext {
            if context.hasChanges {
                try! context.save()
            }
        }
    }
    
    func registerDefaultsFromSettingsBundle() {
        let settingsBundle = Bundle.main.path(forResource: "InAppSettings", ofType: "bundle")!
        let finalPath = URL(fileURLWithPath: settingsBundle).appendingPathComponent("Root.plist")
        let settingsDictionary = NSDictionary(contentsOf: finalPath)
        let preferenceSpecifiers = settingsDictionary?.object(forKey: "PreferenceSpecifiers") as! [AnyObject]
        
        var defaults: [String:Any] = [:]
        
        for item in preferenceSpecifiers {
            if let key = item.object(forKey: "Key") as! String! {
                defaults[key] = item.object(forKey: "DefaultValue")
            }
        }
        
        UserDefaults.standard.register(defaults: defaults)
    }
    
    func migrateLegacyDefaults() {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "server_address_preference") != nil {
            var urlComponents = URLComponents()
            urlComponents.scheme = userDefaults.bool(forKey: "secure_preference") ? "https" : "http"
            urlComponents.host = userDefaults.string(forKey: "server_address_preference")
            urlComponents.port = userDefaults.integer(forKey: "server_port_preference")
            if urlComponents.port == 0 {
                urlComponents.port = 5055
            }
            
            userDefaults.set(urlComponents.string, forKey: "server_url_preference")
            
            userDefaults.removeObject(forKey: "server_port_preference")
            userDefaults.removeObject(forKey: "server_address_preference")
            userDefaults.removeObject(forKey: "secure_preference")
        }
    }

}
