//
// Copyright 2014 - 2017 Anton Tananaev (anton@traccar.org)
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

class StatusViewController: UITableViewController {
    
    static let LIMIT = 20
    static var statusViewController: StatusViewController?
    
    static var messages = [String]()
    
    class func addStartMessage() {
        var message = NSLocalizedString("Service created", comment: "")
        message += "\n\nDevice identifier: "
        message += UserDefaults.standard.string(forKey: "device_id_preference") ?? ""
        message += "\nServer URL: "
        message += UserDefaults.standard.string(forKey: "server_url_preference") ?? ""
        message += "\nLocation accuracy: "
        message += UserDefaults.standard.string(forKey: "accuracy_preference") ?? ""
        message += "\nFrequency: "
        message += String(UserDefaults.standard.double(forKey: "frequency_preference"))
        message += "\nDistance: "
        message += String(UserDefaults.standard.double(forKey: "distance_preference"))
        message += "\nAngle: "
        message += String(UserDefaults.standard.double(forKey: "angle_preference"))
        message += "\nOffline buffering: "
        message += UserDefaults.standard.bool(forKey: "buffer_preference") ? "On" : "Off"
        
        addMessage(message)
    }
    
    class func addMessage(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm - "

        messages.append(formatter.string(from: Date()) + (message))

        if messages.count > LIMIT {
            messages.remove(at: 0)
        }

        statusViewController?.tableView.reloadData()
    }
    
    class func clearMessages() {
        messages.removeAll()

        statusViewController?.tableView.reloadData()
    }

    @IBAction func clear(_ sender: UIBarButtonItem) {
        StatusViewController.clearMessages()
    }
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StatusViewController.statusViewController = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        StatusViewController.statusViewController = nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StatusViewController.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "status"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 24
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.text = StatusViewController.messages[indexPath.row]
        return cell!
    }

}
