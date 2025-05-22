//
//  ProfileViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher
import JGProgressHUD
import Toast_Swift

class ProfileViewController: UIViewController {

    // MARK: - UI组件

    // 头部视图
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primary
        return view
    }()

    // 用户头像
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = AppTheme.Color.background
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = AppTheme.Color.textSecondary
        return imageView
    }()

    // 用户名标签
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.title3()
        label.textColor = .white
        label.text = "未登录"
        return label
    }()

    // 用户ID标签
    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = .white.withAlphaComponent(0.8)
        label.text = "ID: --"
        return label
    }()

    // 编辑资料按钮
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("编辑资料", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTheme.Font.footnote()
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 12
        return button
    }()

    // 功能列表容器
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppTheme.Color.background
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - 数据

    // 功能列表数据
    private let sections: [[String: Any]] = [
        [
            "title": "我的订单",
            "items": [
                ["title": "全部订单", "icon": "list.bullet", "color": AppTheme.Color.primary],
                ["title": "待付款", "icon": "creditcard", "color": AppTheme.Color.warning],
                ["title": "待发货", "icon": "shippingbox", "color": AppTheme.Color.info],
                ["title": "待收货", "icon": "cube", "color": AppTheme.Color.secondary],
                ["title": "待评价", "icon": "star", "color": AppTheme.Color.accent]
            ]
        ],
        [
            "title": "我的服务",
            "items": [
                ["title": "我的宠物", "icon": "pawprint", "color": AppTheme.Color.primary],
                ["title": "收货地址", "icon": "location", "color": AppTheme.Color.info],
                ["title": "我的收藏", "icon": "heart", "color": AppTheme.Color.accent],
                ["title": "优惠券", "icon": "ticket", "color": AppTheme.Color.warning]
            ]
        ],
        [
            "title": "其他服务",
            "items": [
                ["title": "设置", "icon": "gearshape", "color": AppTheme.Color.textSecondary],
                ["title": "帮助中心", "icon": "questionmark.circle", "color": AppTheme.Color.info],
                ["title": "关于我们", "icon": "info.circle", "color": AppTheme.Color.primary],
                ["title": "退出登录", "icon": "arrow.right.square", "color": AppTheme.Color.error]
            ]
        ]
    ]

    // MARK: - 属性

    private let disposeBag = DisposeBag()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()

        // 添加键盘消失手势
        Utilities.addKeyboardDismissGesture(to: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadUserInfo()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - UI设置

    private func setupUI() {
        // 设置背景色
        view.backgroundColor = AppTheme.Color.background

        // 添加子视图
        view.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(userIdLabel)
        headerView.addSubview(editProfileButton)
        view.addSubview(tableView)

        // 设置约束
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }

        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.top.equalTo(avatarImageView).offset(10)
            make.right.equalTo(-20)
        }

        userIdLabel.snp.makeConstraints { make in
            make.left.equalTo(usernameLabel)
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
        }

        editProfileButton.snp.makeConstraints { make in
            make.left.equalTo(usernameLabel)
            make.top.equalTo(userIdLabel.snp.bottom).offset(10)
            make.width.equalTo(80)
            make.height.equalTo(24)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func setupTableView() {
        // 注册单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // 设置数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 监听登录状态变化
        NotificationCenter.default.rx.notification(AppPlist.NotificationName.userDidLogin)
            .subscribe(onNext: { [weak self] _ in
                self?.loadUserInfo()
            })
            .disposed(by: disposeBag)

        // 监听用户信息更新
        NotificationCenter.default.rx.notification(AppPlist.NotificationName.userInfoDidUpdate)
            .subscribe(onNext: { [weak self] _ in
                self?.loadUserInfo()
            })
            .disposed(by: disposeBag)

        // 监听退出登录
        NotificationCenter.default.rx.notification(AppPlist.NotificationName.userDidLogout)
            .subscribe(onNext: { [weak self] _ in
                self?.resetUserInfo()
            })
            .disposed(by: disposeBag)

        // 编辑资料按钮点击
        editProfileButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.editProfileTapped()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 数据加载

    private func loadUserInfo() {
        // 检查登录状态
        guard UserManager.shared.isLoggedIn, let userId = UserManager.shared.currentUser?.id else {
            resetUserInfo()
            return
        }

        // 显示加载指示器
        let hud = Utilities.showLoading(in: view)

        // 从服务器获取最新用户信息
        NetworkManager.shared.request(PetAPI.getUserInfo)
            .subscribe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (user: User) in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 更新用户信息，但不发送通知（避免循环调用）
                    UserManager.shared.updateUserInfo(user, postNotification: false)

                    // 更新UI
                    self?.updateUserInfoUI(user)
                },
                onError: { [weak self] error in
                    // 隐藏加载指示器
                    Utilities.hideLoading(hud)

                    // 显示错误信息
                    Utilities.showError(in: self?.view ?? UIView(), message: "获取用户信息失败: \(error.localizedDescription)")

                    // 使用本地缓存的用户信息
                    if let user = UserManager.shared.currentUser {
                        self?.updateUserInfoUI(user)
                    }
                }
            )
            .disposed(by: disposeBag)
    }

    private func updateUserInfoUI(_ user: User) {
        // 更新用户名
        usernameLabel.text = user.nickname ?? user.username

        // 更新用户ID
        userIdLabel.text = "ID: \(user.id)"

        // 更新头像
        if let avatarURL = user.avatar, !avatarURL.isEmpty, let url = URL(string: avatarURL) {
            avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    private func resetUserInfo() {
        // 重置用户名
        usernameLabel.text = "未登录"

        // 重置用户ID
        userIdLabel.text = "ID: --"

        // 重置头像
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
    }

    // MARK: - 事件处理

    private func editProfileTapped() {
        // 检查登录状态
        guard UserManager.shared.isLoggedIn else {
            // 未登录，提示用户登录
            Utilities.showInfo(in: view, message: "请先登录")
            return
        }

        // TODO: 跳转到编辑资料页面
        Utilities.showInfo(in: view, message: "编辑资料功能即将上线")
    }

    private func handleLogout() {
        // 显示确认对话框
        let alert = UIAlertController(
            title: "退出登录",
            message: "确定要退出登录吗？",
            preferredStyle: .alert
        )

        // 添加取消按钮
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        // 添加确认按钮
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            // 执行退出登录
            UserManager.shared.logout()

            // 跳转到登录页面
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.setupRootViewController()
            }
        })

        // 显示对话框
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = sections[section]["items"] as? [[String: Any]] {
            return items.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // 获取当前项
        if let items = sections[indexPath.section]["items"] as? [[String: Any]],
           let title = items[indexPath.row]["title"] as? String,
           let iconName = items[indexPath.row]["icon"] as? String,
           let color = items[indexPath.row]["color"] as? UIColor {

            // 配置单元格
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.image = UIImage(systemName: iconName)?.withTintColor(color, renderingMode: .alwaysOriginal)
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]["title"] as? String
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 获取当前项
        if let items = sections[indexPath.section]["items"] as? [[String: Any]],
           let title = items[indexPath.row]["title"] as? String {

            // 处理特殊项
            if title == "设置" {
                // TODO: 跳转到设置页面
                Utilities.showInfo(in: view, message: "设置功能即将上线")
            } else if title == "关于我们" {
                // TODO: 跳转到关于我们页面
                Utilities.showInfo(in: view, message: "关于我们功能即将上线")
            } else if title == "退出登录" {
                // 处理退出登录
                if UserManager.shared.isLoggedIn {
                    handleLogout()
                } else {
                    Utilities.showInfo(in: view, message: "您尚未登录")
                }
            } else {
                // 检查登录状态
                guard UserManager.shared.isLoggedIn else {
                    // 未登录，提示用户登录
                    Utilities.showInfo(in: view, message: "请先登录")
                    return
                }

                // 处理其他项
                Utilities.showInfo(in: view, message: "\(title)功能即将上线")
            }
        }
    }
}
