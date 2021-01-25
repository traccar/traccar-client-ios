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
import InAppSettingsKit

class MainViewController: IASKAppSettingsViewController {
    
    var settingsObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Traccar Client", comment: "")
        showCreditsFooter = false
        neverShowPrivacySettings = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.settingsObserver = NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) { (notification) in
            self.didChangeSetting(notification)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = self.settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            UserDefaults.standard.setValue(nil, forKey: "service_status_preference")
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    func didChangeSetting(_ notification: Notification) {
        if let status = notification.userInfo?["service_status_preference"] as? Bool {
            if status && AppDelegate.instance.trackingController == nil {
                let userDefaults = UserDefaults.standard
                let url = userDefaults.string(forKey: "server_url_preference")
                let frequency = userDefaults.integer(forKey: "frequency_preference")
                
                let candidateUrl = NSURL(string: url!)
                
                if candidateUrl == nil || candidateUrl?.host == nil || (candidateUrl?.scheme != "http" && candidateUrl?.scheme != "https") {
                    self.showError("Invalid server URL")
                } else if frequency <= 0 {
                    self.showError("Invalid frequency value")
                } else {
                    StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
                    AppDelegate.instance.trackingController = TrackingController()
                    AppDelegate.instance.trackingController?.start()
                }
            } else if !status && AppDelegate.instance.trackingController != nil {
                StatusViewController.addMessage(NSLocalizedString("Service destroyed", comment: ""))
                AppDelegate.instance.trackingController?.stop()
                AppDelegate.instance.trackingController = nil
            }
        }
    }
    
}
