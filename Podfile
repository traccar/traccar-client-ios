platform :ios, '9.0'

use_frameworks!

# Forces every pod installed to use Swift 5
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "5"
        end
    end
end

target 'FTPTracker' do
  pod 'DataCompression'
  pod 'SwiftSocket'
  pod 'InAppSettingsKit'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end

target 'FTPTrackerTests' do
  pod 'Firebase'
  pod 'InAppSettingsKit'
end
