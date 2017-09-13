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
import InAppSettingsKit

class MainViewController: IASKAppSettingsViewController {
    
    var trackingController: TCTrackingController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Traccar Client", comment: "")
        showCreditsFooter = false
        neverShowPrivacySettings = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            UserDefaults.standard.setValue(nil, forKey: "service_status_preference")
        })
        alert.addAction(defaultAction)
        present(alert, animated: true)
    }

    func defaultsChanged(_ notification: Notification) {
        let defaults = notification.object as? UserDefaults
        let status = (defaults?.bool(forKey: "service_status_preference"))!

        if status && trackingController == nil {
            let validHost = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
            let hostPredicate = NSPredicate(format: "SELF MATCHES %@", validHost)

            let address = (defaults?.string(forKey: "server_address_preference"))!
            let port = (defaults?.integer(forKey: "server_port_preference"))!
            let frequency = (defaults?.integer(forKey: "frequency_preference"))!
            
            if !hostPredicate.evaluate(with: address) {
                showError("Invalid server address")
            } else if port <= 0 || port > 65535 {
                showError("Invalid server port")
            } else if frequency <= 0 {
                showError("Invalid frequency value")
            } else {
                StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
                trackingController = TCTrackingController()
                trackingController?.start()
            }
        } else if !status && trackingController != nil {
            StatusViewController.addMessage(NSLocalizedString("Service destroyed", comment: ""))
            trackingController?.stop()
            trackingController = nil
        }
    }
    
}
