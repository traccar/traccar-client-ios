import AppIntents
import SwiftUI

@available(iOS 16, *)
struct StopTrackingIntent: AppIntent {

  static let title: LocalizedStringResource = "Stop Tracking Service"
    
  func perform() async throws -> some IntentResult & ProvidesDialog {
    var trackingController: TrackingController?
    let userDefaults = UserDefaults.standard
    if userDefaults.bool(forKey: "service_status_preference") {
        userDefaults.setValue(false, forKey: "service_status_preference")
        await StatusViewController.addMessage(NSLocalizedString("Service destroyed", comment: ""))
        trackingController?.stop()
        trackingController = nil
    }
    return .result(dialog: .init(stringLiteral: NSLocalizedString("Service destroyed", comment: "")))
  }
}
