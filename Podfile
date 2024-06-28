source 'https://github.com/CocoaPods/Specs.git'

workspace 'Milton-Coloring'
project 'Milton-Coloring/Milton-Coloring.xcodeproj'

def common_pods
    pod 'Alamofire'
    pod 'Mixpanel'
    pod 'Zip'
    pod 'Purchases'
    pod 'Analytics', '~> 4.1'
    pod 'AppsFlyerFramework'
end

target 'Milton-Coloring' do
    use_frameworks!
    platform :ios, '15.0'
    
    workspace 'Milton-Coloring'
    project 'Milton-Coloring/Milton-Coloring.xcodeproj'
    
    common_pods
    
    pod 'PIOSpriteKit'
    pod 'DevCycle', '~> 1.8.0'
    pod "AlignedCollectionViewFlowLayout"
    pod 'Bugsee'
end


post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            end
        end
    end
end
