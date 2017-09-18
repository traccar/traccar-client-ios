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

    @objc func defaultsChanged(_ notification: Notification) {
        let defaults = notification.object as? UserDefaults
        let status = (defaults?.bool(forKey: "service_status_preference"))!

        if status && AppDelegate.trackingController == nil {
            let url = (defaults?.string(forKey: "server_url_preference"))!
            let frequency = (defaults?.integer(forKey: "frequency_preference"))!

            let candidateUrl = NSURL(string: url)

            if candidateUrl == nil || candidateUrl?.host == nil || (candidateUrl?.scheme != "http" && candidateUrl?.scheme != "https") {
                showError("Invalid server URL")
            } else if frequency <= 0 {
                showError("Invalid frequency value")
            } else {
                StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
                AppDelegate.trackingController = TrackingController()
                AppDelegate.trackingController?.start()
            }
        } else if !status && AppDelegate.trackingController != nil {
            StatusViewController.addMessage(NSLocalizedString("Service destroyed", comment: ""))
            AppDelegate.trackingController?.stop()
            AppDelegate.trackingController = nil
        }
    }
    
}
