# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GoPushDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoPushDemo

end

target 'GoPushNotificationContentExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoPushNotificationContentExtension

end

target 'GoPushNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoPushNotificationServiceExtension

end

target 'GoPushSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GoPushSDK
  pod 'PusherSwift', '8.0.0'
  pod 'Kingfisher'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
  end
end
