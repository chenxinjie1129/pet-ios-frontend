//
//  Utilities.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import JGProgressHUD
import Toast_Swift

/// 通用工具类
class Utilities {
    
    // MARK: - 加载指示器
    
    /// 显示加载指示器
    /// - Parameters:
    ///   - view: 显示在哪个视图上
    ///   - text: 加载文本
    /// - Returns: JGProgressHUD实例
    @discardableResult
    static func showLoading(in view: UIView, text: String = "加载中...") -> JGProgressHUD {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = text
        hud.show(in: view)
        return hud
    }
    
    /// 隐藏加载指示器
    /// - Parameters:
    ///   - hud: JGProgressHUD实例
    ///   - animated: 是否动画
    static func hideLoading(_ hud: JGProgressHUD, animated: Bool = true) {
        hud.dismiss(animated: animated)
    }
    
    // MARK: - Toast提示
    
    /// 显示成功提示
    /// - Parameters:
    ///   - view: 显示在哪个视图上
    ///   - message: 提示信息
    ///   - duration: 显示时长
    static func showSuccess(in view: UIView, message: String, duration: TimeInterval = 2.0) {
        var style = ToastStyle()
        style.backgroundColor = AppTheme.Color.success.withAlphaComponent(0.9)
        view.makeToast(message, duration: duration, position: .center, style: style)
    }
    
    /// 显示错误提示
    /// - Parameters:
    ///   - view: 显示在哪个视图上
    ///   - message: 提示信息
    ///   - duration: 显示时长
    static func showError(in view: UIView, message: String, duration: TimeInterval = 2.0) {
        var style = ToastStyle()
        style.backgroundColor = AppTheme.Color.error.withAlphaComponent(0.9)
        view.makeToast(message, duration: duration, position: .center, style: style)
    }
    
    /// 显示普通提示
    /// - Parameters:
    ///   - view: 显示在哪个视图上
    ///   - message: 提示信息
    ///   - duration: 显示时长
    static func showInfo(in view: UIView, message: String, duration: TimeInterval = 2.0) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.makeToast(message, duration: duration, position: .center, style: style)
    }
    
    // MARK: - 验证工具
    
    /// 验证邮箱格式
    /// - Parameter email: 邮箱字符串
    /// - Returns: 是否有效
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = AppPlist.Regex.email
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    /// 验证手机号格式
    /// - Parameter phone: 手机号字符串
    /// - Returns: 是否有效
    static func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = AppPlist.Regex.phone
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
    
    /// 验证密码格式
    /// - Parameter password: 密码字符串
    /// - Returns: 是否有效
    static func isValidPassword(_ password: String) -> Bool {
        // 简单验证：8位以上
        return password.count >= 8
    }
    
    // MARK: - 键盘工具
    
    /// 添加键盘隐藏手势
    /// - Parameter viewController: 视图控制器
    static func addKeyboardDismissGesture(to viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: viewController, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tap)
    }
}

// MARK: - UIViewController 扩展

extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
