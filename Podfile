platform :ios, '10.0'
use_frameworks!

target 'IntervalApp' do
	pod 'DarwinSDK', :git => 'https://bitbucket.iilg.com/scm/iimob/darwin-sdk-ios.git', branch: 'develop'
	pod 'IntervalUIKit', :git => 'https://bitbucket.iilg.com/scm/iimob/interval-uikit-ios.git', branch: 'develop'
	pod 'Alamofire', :git=>'https://github.com/Alamofire/Alamofire.git', :tag => '4.0.0'
	pod 'FSCalendar' , '~>2.1.1'
	pod 'CVCalendar', :git=>'https://github.com/Mozharovsky/CVCalendar', :tag => '1.4.0'
    pod 'SVProgressHUD'
	pod 'SDWebImage', :git=>'https://github.com/rs/SDWebImage.git', :tag => '3.8.2'
 	pod 'GoogleMaps' , '~>2.2.0'
    pod 'KeychainAccess', :git=> 'https://github.com/kishikawakatsumi/KeychainAccess.git'
 	pod 'SwiftyJSON', :git=>'https://github.com/IBM-Swift/SwiftyJSON'
 	pod 'XCGLogger', :git=>'https://github.com/DaveWoodCom/XCGLogger.git', branch: 'swift_3.0'
    pod 'Brightcove-Player-SDK'
    pod 'Realm' , '~>2.5.0'
    pod 'RealmSwift' , '~>2.5.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
