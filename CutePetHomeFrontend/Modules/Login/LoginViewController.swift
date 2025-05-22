//
//  LoginViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JGProgressHUD

class LoginViewController: UIViewController {

    // MARK: - UI组件

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "萌宠之家"
        label.font = AppTheme.Font.title1()
        label.textColor = AppTheme.Color.primary
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "您的宠物生活好帮手"
        label.font = AppTheme.Font.body(size: 16)
        label.textColor = AppTheme.Color.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名/手机号"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        textField.text = "testuser"
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        textField.text = "12345678"
        return textField
    }()

    private let loginButton: RoundedButton = {
        let button = RoundedButton(style: .primary, title: "登 录")
        button.heightAnchor.constraint(equalToConstant: AppTheme.Metrics.buttonHeightMedium).isActive = true
        return button
    }()

    private let registerButton: RoundedButton = {
        let button = RoundedButton(style: .outline, title: "注 册")
        button.heightAnchor.constraint(equalToConstant: AppTheme.Metrics.buttonHeightMedium).isActive = true
        return button
    }()

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("忘记密码?", for: .normal)
        button.setTitleColor(AppTheme.Color.textTertiary, for: .normal)
        button.titleLabel?.font = AppTheme.Font.footnote()
        return button
    }()

    // MARK: - 属性

    private let disposeBag = DisposeBag()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Utilities.addKeyboardDismissGesture(to: self)
    }

    // MARK: - UI设置

    private func setupUI() {
        // 设置背景色
        view.backgroundColor = .white

        // 添加子视图
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(forgotPasswordButton)

        // 设置约束
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(AppTheme.Metrics.textFieldHeight)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.left.right.height.equalTo(usernameTextField)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.left.right.equalTo(usernameTextField)
        }

        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.left.right.equalTo(loginButton)
        }

        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 登录按钮点击事件
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.login()
            })
            .disposed(by: disposeBag)

        // 注册按钮点击事件
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToRegister()
            })
            .disposed(by: disposeBag)

        // 忘记密码按钮点击事件
        forgotPasswordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showForgotPasswordAlert()
            })
            .disposed(by: disposeBag)

        // 输入框回车键处理
        usernameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.passwordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        passwordTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.login()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 操作方法

    private func login() {
        // 验证输入
        guard let username = usernameTextField.text, !username.isEmpty else {
            Utilities.showError(in: view, message: "请输入用户名或手机号")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            Utilities.showError(in: view, message: "请输入密码")
            return
        }

        // 显示加载指示器
        let hud = Utilities.showLoading(in: view)

        // 发送登录请求
        NetworkManager.shared.request(PetAPI.login(username: username, password: password))
            .subscribe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (response: LoginResponse) in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 创建用户对象
                    let user = User(
                        id: response.userId,
                        username: response.username,
                        nickname: response.nickname,
                        mobile: nil,
                        email: nil,
                        avatar: response.avatar,
                        gender: nil,
                        status: nil,
                        lastLoginTime: nil,
                        lastLoginIp: nil,
                        createTime: nil,
                        updateTime: nil
                    )

                    // 保存登录信息
                    if let token = response.token {
                        UserManager.shared.saveLoginInfo(token: token, user: user)
                    } else {
                        // 如果没有token，使用用户ID作为临时token（不推荐）
                        Utilities.showError(in: self?.view ?? UIView(), message: "登录成功但未获取到有效令牌")
                        UserManager.shared.saveLoginInfo(token: "\(response.userId)", user: user)
                    }

                    // 显示成功提示
                    Utilities.showSuccess(in: self?.view ?? UIView(), message: "登录成功")

                    // 跳转到主页
                    self?.navigateToMainTabBar()
                },
                onError: { [weak self] error in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 显示错误提示
                    Utilities.showError(in: self?.view ?? UIView(), message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }

    private func navigateToRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }

    private func navigateToMainTabBar() {
        let mainTabBarController = MainTabBarController()
        UIApplication.shared.windows.first?.rootViewController = mainTabBarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    private func showForgotPasswordAlert() {
        let alert = UIAlertController(title: "忘记密码", message: "请输入您的手机号，我们将发送验证码帮您重置密码", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "请输入手机号"
            textField.keyboardType = .phonePad
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let confirmAction = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            if let phoneTextField = alert.textFields?.first, let phone = phoneTextField.text, !phone.isEmpty {
                if Utilities.isValidPhone(phone) {
                    self?.sendVerificationCode(phone: phone)
                } else {
                    Utilities.showError(in: self?.view ?? UIView(), message: "请输入有效的手机号")
                }
            } else {
                Utilities.showError(in: self?.view ?? UIView(), message: "请输入手机号")
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    private func sendVerificationCode(phone: String) {
        // 显示加载指示器
        let hud = Utilities.showLoading(in: view)

        // 发送验证码请求
        NetworkManager.shared.request(PetAPI.sendVerificationCode(phone: phone))
            .subscribe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (_: EmptyResponse) in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 显示成功提示
                    Utilities.showSuccess(in: self?.view ?? UIView(), message: "验证码已发送，请注意查收")
                },
                onError: { [weak self] error in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 显示错误提示
                    Utilities.showError(in: self?.view ?? UIView(), message: error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}


