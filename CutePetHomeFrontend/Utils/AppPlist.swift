//
//  AppPlist.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation

/// 应用常量配置
struct AppPlist {

    /// 服务器配置
    struct Server {
        #if DEBUG
        // 开发环境
        static let baseURL = "http://localhost:8080/api"
        #else
        // 生产环境
        static let baseURL = "https://api.petshome.com/api"
        #endif

        // API版本
        static let apiVersion = ""

        // 完整的API基础URL
        static var apiBaseURL: String {
            return baseURL
        }

        // 图片服务器URL
        static let imageBaseURL = "https://img.petshome.com"
    }

    /// 应用信息
    struct App {
        // 应用版本
        static var version: String {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        }

        // 应用构建版本
        static var buildVersion: String {
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        }

        // 应用名称
        static var name: String {
            return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "萌宠之家"
        }

        // 应用Bundle ID
        static var bundleIdentifier: String {
            return Bundle.main.bundleIdentifier ?? "com.petshome.app"
        }
    }

    /// 本地存储Key
    struct StorageKey {
        // 用户相关
        static let userToken = "user_token"
        static let userInfo = "user_info"
        static let isLoggedIn = "is_logged_in"

        // 设置相关
        static let appTheme = "app_theme"
        static let notificationEnabled = "notification_enabled"

        // 缓存相关
        static let lastUpdateTime = "last_update_time"
    }

    /// 通知名称
    struct NotificationName {
        static let userDidLogin = Notification.Name("userDidLogin")
        static let userDidLogout = Notification.Name("userDidLogout")
        static let userInfoDidUpdate = Notification.Name("userInfoDidUpdate")
    }

    /// 时间格式
    struct DateFormat {
        static let standard = "yyyy-MM-dd HH:mm:ss"
        static let date = "yyyy-MM-dd"
        static let time = "HH:mm:ss"
        static let monthDay = "MM-dd"
        static let yearMonth = "yyyy-MM"
    }

    /// 正则表达式
    struct Regex {
        static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        static let phone = "^1[3-9]\\d{9}$"
        static let password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
    }
}
