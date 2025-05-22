//
//  User.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation

/// 用户模型
struct User: Codable {
    let id: Int
    let username: String
    let nickname: String?
    let mobile: String?
    let email: String?
    let avatar: String?
    let gender: Int?
    let status: Int?
    let lastLoginTime: String?
    let lastLoginIp: String?
    let createTime: String?
    let updateTime: String?

    enum CodingKeys: String, CodingKey {
        case id, username, nickname, mobile, email, avatar, gender, status
        case lastLoginTime = "lastLoginTime"
        case lastLoginIp = "lastLoginIp"
        case createTime = "createTime"
        case updateTime = "updateTime"
    }
}

/// 登录响应
struct LoginResponse: Codable {
    let userId: Int
    let username: String
    let nickname: String?
    let avatar: String?
    let token: String?

    enum CodingKeys: String, CodingKey {
        case userId, username, nickname, avatar, token
    }
}

/// 用户管理器
class UserManager {

    // 单例
    static let shared = UserManager()

    // 私有初始化方法
    private init() {}

    // 当前用户
    private(set) var currentUser: User?

    // 是否已登录
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: AppPlist.StorageKey.isLoggedIn)
    }

    // 用户Token
    var token: String? {
        return UserDefaults.standard.string(forKey: AppPlist.StorageKey.userToken)
    }

    // MARK: - 用户操作

    /// 保存登录信息
    /// - Parameters:
    ///   - token: 用户令牌
    ///   - user: 用户信息
    func saveLoginInfo(token: String, user: User) {
        // 保存Token
        UserDefaults.standard.set(token, forKey: AppPlist.StorageKey.userToken)

        // 保存用户信息
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: AppPlist.StorageKey.userInfo)
        }

        // 设置登录状态
        UserDefaults.standard.set(true, forKey: AppPlist.StorageKey.isLoggedIn)

        // 更新当前用户
        currentUser = user

        // 发送登录通知
        NotificationCenter.default.post(name: AppPlist.NotificationName.userDidLogin, object: nil)
    }

    /// 加载用户信息
    func loadUserInfo() {
        if let userData = UserDefaults.standard.data(forKey: AppPlist.StorageKey.userInfo),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
        }
    }

    /// 更新用户信息
    /// - Parameters:
    ///   - user: 新的用户信息
    ///   - postNotification: 是否发送通知，默认为true
    func updateUserInfo(_ user: User, postNotification: Bool = true) {
        // 保存用户信息
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: AppPlist.StorageKey.userInfo)
        }

        // 更新当前用户
        currentUser = user

        // 发送用户信息更新通知
        if postNotification {
            NotificationCenter.default.post(name: AppPlist.NotificationName.userInfoDidUpdate, object: nil)
        }
    }

    /// 退出登录
    func logout() {
        // 清除Token
        UserDefaults.standard.removeObject(forKey: AppPlist.StorageKey.userToken)

        // 清除用户信息
        UserDefaults.standard.removeObject(forKey: AppPlist.StorageKey.userInfo)

        // 设置登录状态
        UserDefaults.standard.set(false, forKey: AppPlist.StorageKey.isLoggedIn)

        // 清除当前用户
        currentUser = nil

        // 发送退出登录通知
        NotificationCenter.default.post(name: AppPlist.NotificationName.userDidLogout, object: nil)
    }
}
