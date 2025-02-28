import AppIntents
import SwiftUI

@available(iOS 16, *)
struct StartTrackingIntent: AppIntent {
  
  static let title: LocalizedStringResource = "Start Tracking Service"
    
  func perform() async throws -> some IntentResult & ProvidesDialog {
    var trackingController: TrackingController?
    let userDefaults = UserDefaults.standard
    if !userDefaults.bool(forKey: "service_status_preference") {
        userDefaults.setValue(true, forKey: "service_status_preference")
        await StatusViewController.addMessage(NSLocalizedString("Service created", comment: ""))
        trackingController = TrackingController()
        trackingController?.start()
    }
      return .result(dialog: .init(stringLiteral: NSLocalizedString("Service created", comment: "")))
  }
}
