//
//  SceneDelegate.swift
//  CutePetHomeFrontend
//
//  Created by chenxinjie on 2025/5/19.
//

import UIKit
import IQKeyboardManagerSwift
import Kingfisher

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 创建窗口
        window = UIWindow(windowScene: windowScene)

        // 根据登录状态设置根视图控制器
        setupRootViewController()
        window?.makeKeyAndVisible()

        // 设置IQKeyboardManager
        setupIQKeyboardManager()

        // 注册模拟图片
        registerMockImages()
    }

    // MARK: - 根视图控制器设置

    /// 根据登录状态设置根视图控制器
    func setupRootViewController() {
        // 加载用户信息
        UserManager.shared.loadUserInfo()

        // 根据登录状态设置根视图控制器
        if UserManager.shared.isLoggedIn {
            // 已登录，显示主标签栏
            window?.rootViewController = MainTabBarController()
        } else {
            // 未登录，显示登录界面
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navigationController
        }
    }

    // MARK: - 键盘管理设置

    private func setupIQKeyboardManager() {
        // 配置键盘管理器
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    // MARK: - 模拟图片注册

    /// 注册模拟图片到Kingfisher缓存
    private func registerMockImages() {
        // 注册轮播图图片
        for i in 0..<3 {
            let image = MockImageGenerator.generateBannerImage(index: i)
            let key = "banner_\(i+1)"
            KingfisherManager.shared.cache.store(image, forKey: key)
        }

        // 注册知识图片
        for i in 0..<3 {
            let image = MockImageGenerator.generateKnowledgeImage(index: i)
            let key = "knowledge_\(i+1)"
            KingfisherManager.shared.cache.store(image, forKey: key)
        }
    }
}

