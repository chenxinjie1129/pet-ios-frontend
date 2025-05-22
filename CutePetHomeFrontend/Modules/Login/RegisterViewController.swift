//
//  RegisterViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JGProgressHUD

class RegisterViewController: UIViewController {

    // MARK: - UI组件

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "注册账号"
        label.font = AppTheme.Font.title2()
        label.textColor = AppTheme.Color.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "用户名"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        return textField
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "手机号"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.keyboardType = .phonePad
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        return textField
    }()

    private let verificationCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "验证码"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.keyboardType = .numberPad
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        return textField
    }()

    private let sendCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送验证码", for: .normal)
        button.setTitleColor(AppTheme.Color.primary, for: .normal)
        button.titleLabel?.font = AppTheme.Font.body(size: 14)
        return button
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "密码（8位以上）"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .next
        textField.isSecureTextEntry = true
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        return textField
    }()

    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "确认密码"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        textField.font = AppTheme.Font.body()
        textField.backgroundColor = AppTheme.Color.background
        return textField
    }()

    private let registerButton: RoundedButton = {
        let button = RoundedButton(style: .primary, title: "注 册")
        button.heightAnchor.constraint(equalToConstant: AppTheme.Metrics.buttonHeightMedium).isActive = true
        return button
    }()

    private let backToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("已有账号？返回登录", for: .normal)
        button.setTitleColor(AppTheme.Color.primary, for: .normal)
        button.titleLabel?.font = AppTheme.Font.body(size: 14)
        return button
    }()

    // MARK: - 属性

    private let disposeBag = DisposeBag()
    private var countdownTimer: Timer?
    private var countdown = 60

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Utilities.addKeyboardDismissGesture(to: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    // MARK: - UI设置

    private func setupUI() {
        // 设置背景色
        view.backgroundColor = .white

        // 设置导航栏
        title = "注册"

        // 添加子视图
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(phoneTextField)
        view.addSubview(verificationCodeTextField)
        view.addSubview(sendCodeButton)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(registerButton)
        view.addSubview(backToLoginButton)

        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalToSuperview()
        }

        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(AppTheme.Metrics.textFieldHeight)
        }

        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(20)
            make.left.right.height.equalTo(usernameTextField)
        }

        verificationCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
            make.left.height.equalTo(usernameTextField)
            make.right.equalTo(sendCodeButton.snp.left).offset(-10)
        }

        sendCodeButton.snp.makeConstraints { make in
            make.centerY.equalTo(verificationCodeTextField)
            make.right.equalTo(usernameTextField)
            make.width.equalTo(100)
            make.height.equalTo(AppTheme.Metrics.buttonHeightSmall)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(20)
            make.left.right.height.equalTo(usernameTextField)
        }

        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.right.height.equalTo(usernameTextField)
        }

        registerButton.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(40)
            make.left.right.equalTo(usernameTextField)
        }

        backToLoginButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 注册按钮点击事件
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.register()
            })
            .disposed(by: disposeBag)

        // 返回登录按钮点击事件
        backToLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        // 发送验证码按钮点击事件
        sendCodeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendVerificationCode()
            })
            .disposed(by: disposeBag)

        // 输入框回车键处理
        usernameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.phoneTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        phoneTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.verificationCodeTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        verificationCodeTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.passwordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        passwordTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.confirmPasswordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        confirmPasswordTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.register()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 操作方法

    private func register() {
        // 验证输入
        guard let username = usernameTextField.text, !username.isEmpty else {
            Utilities.showError(in: view, message: "请输入用户名")
            return
        }

        guard let phone = phoneTextField.text, !phone.isEmpty else {
            Utilities.showError(in: view, message: "请输入手机号")
            return
        }

        guard Utilities.isValidPhone(phone) else {
            Utilities.showError(in: view, message: "请输入有效的手机号")
            return
        }

        guard let code = verificationCodeTextField.text, !code.isEmpty else {
            Utilities.showError(in: view, message: "请输入验证码")
            return
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            Utilities.showError(in: view, message: "请输入密码")
            return
        }

        guard Utilities.isValidPassword(password) else {
            Utilities.showError(in: view, message: "密码长度至少为8位")
            return
        }

        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            Utilities.showError(in: view, message: "两次输入的密码不一致")
            return
        }

        // 显示加载指示器
        let hud = Utilities.showLoading(in: view)

        // 直接发送注册请求，不再先验证验证码
        // 注意：如果后端需要验证码验证，应该在注册接口中处理
        NetworkManager.shared.request(PetAPI.register(username: username, password: password, phone: phone))
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
                        Utilities.showError(in: self?.view ?? UIView(), message: "注册成功但未获取到有效令牌")
                        UserManager.shared.saveLoginInfo(token: "\(response.userId)", user: user)
                    }

                    // 显示成功提示
                    Utilities.showSuccess(in: self?.view ?? UIView(), message: "注册成功")

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

    private func sendVerificationCode() {
        // 验证手机号
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            Utilities.showError(in: view, message: "请输入手机号")
            return
        }

        guard Utilities.isValidPhone(phone) else {
            Utilities.showError(in: view, message: "请输入有效的手机号")
            return
        }

        // 禁用发送按钮
        sendCodeButton.isEnabled = false

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

                    // 开始倒计时
                    self?.startCountdown()
                },
                onError: { [weak self] error in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 显示错误提示
                    Utilities.showError(in: self?.view ?? UIView(), message: error.localizedDescription)

                    // 启用发送按钮
                    self?.sendCodeButton.isEnabled = true
                }
            )
            .disposed(by: disposeBag)
    }

    private func startCountdown() {
        countdown = 60
        updateSendCodeButtonTitle()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.countdown -= 1
            self.updateSendCodeButtonTitle()

            if self.countdown <= 0 {
                timer.invalidate()
                self.sendCodeButton.isEnabled = true
                self.sendCodeButton.setTitle("发送验证码", for: .normal)
            }
        }
    }

    private func updateSendCodeButtonTitle() {
        sendCodeButton.setTitle("\(countdown)秒后重发", for: .normal)
    }

    private func navigateToMainTabBar() {
        let mainTabBarController = MainTabBarController()
        UIApplication.shared.windows.first?.rootViewController = mainTabBarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
