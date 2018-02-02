platform :ios, '10.0'
use_frameworks!

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

def testing_build_dependencies
    pod 'Realm','~>2.8.3'
    pod 'Firebase/Core','~>4.3.0'
    pod 'Brightcove-Player-SDK','~>5.3.4'
    pod 'GoogleMaps' , '~>2.2.0'
    pod 'Bond', :git=>'https://github.com/ReactiveKit/Bond.git', :tag => '6.3.0'
    pod 'thenPromise', :git=>'https://github.com/freshOS/then.git', :tag => '2.2.5'
end

target 'IntervalApp' do
    pod 'Realm','~>2.8.3'
    pod 'Appsee','~>2.3.5'
    pod 'RMessage','~>2.1.5'
    pod 'SwiftLint','~>0.22.0'
    pod 'RealmSwift','~>2.8.3'
    pod 'SwiftyJSON','~>3.1.4'
    pod 'Firebase/Core','~>4.3.0'
    pod 'SVProgressHUD','~>2.2.1'
    pod 'AdobeMobileSDK','~>4.13.8'
    pod 'Firebase/Messaging','~>4.3.0'
    pod 'TPKeyboardAvoiding','~>1.3.1'
    pod 'Brightcove-Player-SDK','~>5.3.4'
    pod 'FSCalendar', '~>2.1.1'
    pod 'GoogleMaps', '~>2.2.0'
    pod 'HockeySDK', :subspecs => ['AllFeaturesLib']
    pod 'Bond', :git=>'https://github.com/ReactiveKit/Bond.git', :tag => '6.3.0'
    pod 'thenPromise', :git=>'https://github.com/freshOS/then.git', :tag => '2.2.5'
    pod 'SDWebImage', :git=>'https://github.com/rs/SDWebImage.git', :tag => '3.8.2'
    pod 'Alamofire', :git=>'https://github.com/Alamofire/Alamofire.git', :tag => '4.0.0'
    pod 'CVCalendar', :git=>'https://github.com/Mozharovsky/CVCalendar', :tag => '1.4.0'
    pod 'XCGLogger', :git=>'https://github.com/DaveWoodCom/XCGLogger.git', branch: 'swift_3.0'
    pod 'ReactiveKit', :git=>'https://github.com/ReactiveKit/ReactiveKit.git', :tag => 'v3.6.2'
    pod 'IntervalUIKit', :git => 'https://bitbucket.iilg.com/scm/iimob/interval-uikit-ios.git', :commit => 'ee050d2e'
    pod 'DarwinSDK', :git => 'https://bitbucket.iilg.com/scm/iimob/darwin-sdk-ios.git', branch: 'develop', :commit => 'bfc742d5'
end

target 'IntervalAppTests' do
    testing_pods
    testing_build_dependencies
end
