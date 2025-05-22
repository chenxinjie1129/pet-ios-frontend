# Uncomment the next line to define a global platform for your project

source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '14.0'

target 'CutePetHomeFrontend' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CutePetHomeFrontend
  
  # 网络请求
  pod 'Alamofire', '~> 5.7.1'
  pod 'Moya', '~> 15.0.0'
  pod 'Moya/RxSwift', '~> 15.0.0'
  
  # 响应式编程
  pod 'RxSwift', '~> 6.6.0'
  pod 'RxCocoa', '~> 6.6.0'
  
  # 图片加载与缓存
  pod 'Kingfisher', '~> 7.9.1'
  
  # 界面相关
  pod 'SnapKit', '~> 5.6.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.16'
  pod 'JGProgressHUD', '~> 2.2.0'
  pod 'FSPagerView'
  pod 'MJRefresh', '~> 3.7.5'
  
  # 数据存储
  pod 'RealmSwift', '~> 10.44.0'
  
  # 用户体验
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'EmptyDataSet-Swift'
  
  # 分析与监控
  pod 'Firebase/Analytics'
  pod 'Bugly', '~> 2.5.91'
  
  # 数据持久化
  pod 'FMDB', '~> 2.7.5'
  pod 'KeychainAccess', '~> 4.2.2'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
