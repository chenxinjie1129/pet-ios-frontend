# 萌宠之家 iOS客户端

## 项目概述
萌宠之家是一款面向宠物主人的综合服务平台，提供宠物用品购买、宠物健康咨询、美容护理预约、宠物社区等功能。

## 技术栈
- 开发语言：Swift 5
- 架构模式：MVVM-C
- 网络层：Alamofire + Moya
- 响应式：RxSwift
- UI布局：SnapKit
- 图片加载：Kingfisher
- 数据存储：RealmSwift + UserDefaults

## 目录结构
```
CutePetHomeFrontend/
├── AppEntry/                # 应用入口（主TabBar等）
├── Common/                  # 公共组件（如BannerView、通用卡片等）
├── Modules/                 # 业务模块
│   ├── Home/                # 首页模块
│   ├── Mall/                # 商城模块
│   ├── Points/              # 积分商城模块
│   ├── Profile/             # 个人中心模块
│   └── Login/               # 登录注册模块
├── Networking/              # 网络层封装
├── Services/                # 服务层（预留）
├── Utils/                   # 工具类、主题、通用组件
│   ├── Components/          # 通用UI组件（如RoundedButton）
│   ├── AppPlist.swift       # 常量配置
│   ├── AppTheme.swift       # 主题色/字体
│   └── Utilities.swift      # 通用工具方法
├── Assets.xcassets/         # 图片资源
├── Base.lproj/              # 启动图、主Storyboard
├── AppDelegate.swift        # App生命周期
├── SceneDelegate.swift      # 场景生命周期
├── Info.plist               # 配置文件
├── ViewController.swift     # 默认入口
├── project.pbxproj          # Xcode工程文件
├── Podfile                  # CocoaPods依赖
├── Podfile.lock             # Pods锁定
├── CutePetHomeFrontend.xcodeproj/    # Xcode工程目录
├── CutePetHomeFrontend.xcworkspace/  # Xcode工作区
└── README.md                # 项目说明
```

## 开发规范
- 命名规范：大驼峰命名类名，小驼峰命名变量和方法
- 颜色主题：使用AppTheme统一管理
- 国际化：所有字符串使用本地化
- 图片资源：使用Assets管理，支持深色模式 

## 网络请求配置规范
- 服务器URL配置：统一在`Utils/AppPlist.swift`的`Server`结构体中管理
- API路径定义：所有API路径定义统一在`Networking/NetworkManager.swift`的`PetAPI`枚举中管理
- 请勿在多处定义相同的API路径，避免维护困难
- 所有网络请求必须通过`NetworkManager.shared.request()`方法发起 