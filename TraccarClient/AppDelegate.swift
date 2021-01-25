//
// Copyright 2013 - 2021 Anton Tananaev (anton@traccar.org)
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
class AppDelegate: UIResponder, UIApplicationDelegate, PositionProviderDelegate {
    
    var window: UIWindow?
    
    var managedObjectContext: NSManagedObjectContext?
    var managedObjectModel: NSManagedObjectModel?
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    var trackingController: TrackingController?
    var positionProvider: PositionProvider?
    
    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        #if FIREBASE
        FirebaseApp.configure()
        #endif

        UIDevice.current.isBatteryMonitoringEnabled = true

        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "device_id_preference") == nil {
            let identifier = "\(Int.random(in: 100000..<1000000))"
            userDefaults.setValue(identifier, forKey: "device_id_preference")
        }

        registerDefaultsFromSettingsBundle()
        
        migrateLegacyDefaults()
        
        let modelUrl = Bundle.main.url(forResource: "TraccarClient", withExtension: "momd")
        managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl!)
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("TraccarClient.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: options)
        
        managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator

        if userDefaults.bool(forKey: "service_status_preference") {
            StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
            trackingController = TrackingController()
            trackingController?.start()
        }

        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        let userDefaults = UserDefaults.standard
        
        switch shortcutItem.type {
        case "org.traccar.client.start":
            if !userDefaults.bool(forKey: "service_status_preference") {
                userDefaults.setValue(true, forKey: "service_status_preference")
                StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
                trackingController = TrackingController()
                trackingController?.start()
                showToast(message: NSLocalizedString("Service created", comment: ""))
            }
        case "org.traccar.client.stop":
            if userDefaults.bool(forKey: "service_status_preference") {
                userDefaults.setValue(false, forKey: "service_status_preference")
                StatusViewController.addMessage(NSLocalizedString("Service destroyed", comment: ""))
                trackingController?.stop()
                trackingController = nil
                showToast(message: NSLocalizedString("Service destroyed", comment: ""))
            }
        case "org.traccar.client.sos":
            positionProvider = PositionProvider()
            positionProvider?.delegate = self
            positionProvider?.startUpdates()
        default:
            break
        }
        
        completionHandler(true)
    }
    
    func didUpdate(position: Position) {

        positionProvider?.stopUpdates()
        positionProvider = nil

        let userDefaults = UserDefaults.standard
        
        if let request = ProtocolFormatter.formatPostion(position, url: userDefaults.string(forKey: "server_url_preference")!, alarm: "sos") {
            RequestManager.sendRequest(request, completionHandler: {(_ success: Bool) -> Void in
                if success {
                    self.showToast(message: NSLocalizedString("Send successfully", comment: ""))
                } else {
                    self.showToast(message: NSLocalizedString("Send failed", comment: ""))
                }
            })
        }
    }
    
    func showToast(message : String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        window?.rootViewController?.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
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
        let preferenceSpecifiers = settingsDictionary?.object(forKey: "PreferenceSpecifiers") as! [NSDictionary]
        
        var defaults: [String:Any] = [:]
        
        for item in preferenceSpecifiers {
            if let key = item.object(forKey: "Key") as? String {
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
