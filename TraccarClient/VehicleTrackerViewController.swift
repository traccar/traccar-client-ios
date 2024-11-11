//
//  VehicleTrackerViewController.swift
//  TraccarClient
//
//  Created by Balleng Balleng on 2024/11/11.
//  Copyright © 2024 Traccar. All rights reserved.
//

import UIKit

class VehicleTrackerViewController: UIViewController {

    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var sosButton: UIButton!
    @IBOutlet weak var vehicleView: UIView!
    @IBOutlet weak var vehicleReg: UILabel!
    @IBOutlet weak var clockInAndOut: UIButton!
    @IBOutlet weak var settings: UIButton!
    
    @IBOutlet weak var grayOutView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var vehicleRegistration: UITextField!
    @IBOutlet weak var cancelSettings: UIButton!
    @IBOutlet weak var saveSettings: UIButton!
    
    var viewModel: VehicleTrackerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = VehicleTrackerViewModel()
        setupView()
    }
    
    func setupView() {
        connectedLabel.layer.borderWidth = 1.5
        connectedLabel.layer.borderColor = UIColor(named: "trailblazer-light-green")?.cgColor
        connectedLabel.layer.cornerRadius = 16
        
        vehicleView.layer.cornerRadius = 16
        vehicleReg.text = viewModel?.deviceIdentifier
        
        clockInAndOut.layer.cornerRadius = 16
        clockInAndOut.setTitle(self.viewModel?.clockInOrOut, for: .normal)
        clockInAndOut.setImage(UIImage(named: "PlayFill"), for: .normal)
        
        settings.layer.cornerRadius = settings.frame.height / 2
        
        grayOutView.isHidden = true
        settingsView.layer.cornerRadius = 16
        saveSettings.layer.cornerRadius = 16
        
        vehicleRegistration.text = viewModel?.deviceIdentifier
    }

    @IBAction func clockInOrOut(_ sender: UIButton) {
        viewModel?.clockIn.toggle()
        if viewModel?.clockIn == true {
            clockInAndOut.setImage(UIImage(named: "PauseFill"), for: .normal)
        } else {
            clockInAndOut.setImage(UIImage(named: "PlayFill"), for: .normal)
        }
        clockInAndOut.setTitle(self.viewModel?.clockInOrOut, for: .normal)
    }
    
    @IBAction func showSettings(_ sender: UIButton) {
        grayOutView.isHidden = false
        vehicleRegistration.text = viewModel?.deviceIdentifier
    }
    
    @IBAction func cancelSettings(_ sender: UIButton) {
        grayOutView.isHidden = true
        // TODO: reset device identifier
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        if let registration = vehicleRegistration.text, vehicleRegistration.text != "" {
            viewModel?.deviceIdentifier = registration
            vehicleReg.text = viewModel?.deviceIdentifier
            grayOutView.isHidden = true
            // TODO: send changes to the back-end
        }
    }
}
