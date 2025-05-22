//
//  MainTabBarController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import RxSwift
import RxCocoa

// 导入模块
import SnapKit

// 导入自定义模块
import FSPagerView

// 导入视图控制器
import Kingfisher

class MainTabBarController: UITabBarController {

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }

    // MARK: - 设置方法

    private func setupTabBar() {
        // 设置TabBar外观
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = .white
        }

        // 设置TabBar选中颜色
        tabBar.tintColor = AppTheme.Color.primary
        tabBar.unselectedItemTintColor = AppTheme.Color.textTertiary
    }

    private func setupViewControllers() {
        // 创建视图控制器
        let homeVC = createHomeViewController()
        let mallVC = createMallViewController()
        let profileVC = createProfileViewController()

        // 设置TabBar视图控制器
        viewControllers = [homeVC, mallVC, profileVC]
    }

    // MARK: - 创建视图控制器

    private func createHomeViewController() -> UINavigationController {
        // 创建首页视图控制器
        let homeVC = HomeViewController()

        // 设置TabBar项
        homeVC.tabBarItem = UITabBarItem(
            title: "首页",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // 创建导航控制器
        let navController = UINavigationController(rootViewController: homeVC)
        setupNavigationBar(navController.navigationBar)

        return navController
    }

    private func createMallViewController() -> UINavigationController {
        // 创建商城视图控制器（临时使用占位视图控制器）
        let mallVC = createPlaceholderViewController(title: "商城", message: "商城内容将在这里显示")

        // 设置TabBar项
        mallVC.tabBarItem = UITabBarItem(
            title: "商城",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )

        // 创建导航控制器
        let navController = UINavigationController(rootViewController: mallVC)
        setupNavigationBar(navController.navigationBar)

        return navController
    }

    private func createProfileViewController() -> UINavigationController {
        // 创建个人中心视图控制器
        let profileVC = ProfileViewController()

        // 设置TabBar项
        profileVC.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        // 创建导航控制器
        let navController = UINavigationController(rootViewController: profileVC)
        setupNavigationBar(navController.navigationBar)

        return navController
    }

    // MARK: - 辅助方法

    private func setupNavigationBar(_ navigationBar: UINavigationBar) {
        // 设置导航栏外观
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [
                .foregroundColor: AppTheme.Color.textPrimary,
                .font: AppTheme.Font.title3()
            ]

            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = .white
            navigationBar.titleTextAttributes = [
                .foregroundColor: AppTheme.Color.textPrimary,
                .font: AppTheme.Font.title3()
            ]
        }

        navigationBar.tintColor = AppTheme.Color.primary
    }

    private func createPlaceholderViewController(title: String, message: String) -> UIViewController {
        let viewController = UIViewController()
        viewController.title = title
        viewController.view.backgroundColor = .white

        // 创建标签
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = AppTheme.Color.textSecondary
        label.font = AppTheme.Font.body()
        label.numberOfLines = 0

        // 添加到视图
        viewController.view.addSubview(label)

        // 设置约束
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20)
        ])

        return viewController
    }
}
