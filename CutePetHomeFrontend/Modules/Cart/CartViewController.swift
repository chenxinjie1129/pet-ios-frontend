//
//  CartViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CartViewController: UIViewController {

    // MARK: - UI组件

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = AppTheme.Color.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cart")
        imageView.tintColor = AppTheme.Color.textTertiary
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "购物车空空如也"
        titleLabel.font = AppTheme.Font.title3()
        titleLabel.textColor = AppTheme.Color.textSecondary
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "快去挑选心仪的商品吧"
        subtitleLabel.font = AppTheme.Font.body()
        subtitleLabel.textColor = AppTheme.Color.textTertiary
        subtitleLabel.textAlignment = .center

        let goShoppingButton = UIButton(type: .system)
        goShoppingButton.setTitle("去逛逛", for: .normal)
        goShoppingButton.setTitleColor(.white, for: .normal)
        goShoppingButton.titleLabel?.font = AppTheme.Font.body(weight: .medium)
        goShoppingButton.backgroundColor = AppTheme.Color.primary
        goShoppingButton.layer.cornerRadius = 20

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(goShoppingButton)

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        goShoppingButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
        }

        goShoppingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tabBarController?.selectedIndex = 1 // 跳转到商城
            })
            .disposed(by: disposeBag)

        return view
    }()

    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1

        // 添加顶部分隔线
        let separatorLine = UIView()
        separatorLine.backgroundColor = AppTheme.Color.border
        view.addSubview(separatorLine)

        separatorLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        return view
    }()

    private lazy var selectAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.setTitle("全选", for: .normal)
        button.setTitleColor(AppTheme.Color.textPrimary, for: .normal)
        button.titleLabel?.font = AppTheme.Font.body(size: 14)
        button.tintColor = AppTheme.Color.primary
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.contentHorizontalAlignment = .left
        return button
    }()

    private lazy var priceContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 18, weight: .bold)
        label.textColor = AppTheme.Color.accent
        label.text = "¥0.00"
        label.textAlignment = .right
        return label
    }()

    private lazy var originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 12)
        label.textColor = AppTheme.Color.textTertiary
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    private lazy var checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("结算", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTheme.Font.body(size: 16, weight: .medium)
        button.backgroundColor = AppTheme.Color.primary
        button.layer.cornerRadius = 20
        return button
    }()

    // MARK: - 属性

    private let viewModel = CartViewModel()
    private let disposeBag = DisposeBag()
    private var cartItems: [CartItem] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - UI设置

    private func setupUI() {
        title = "购物车"
        view.backgroundColor = AppTheme.Color.background

        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(bottomContainer)

        bottomContainer.addSubview(selectAllButton)
        bottomContainer.addSubview(priceContainer)
        bottomContainer.addSubview(checkoutButton)

        priceContainer.addSubview(totalPriceLabel)
        priceContainer.addSubview(originalPriceLabel)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }

        bottomContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }

        selectAllButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        checkoutButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }

        priceContainer.snp.makeConstraints { make in
            make.right.equalTo(checkoutButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(80)
        }

        totalPriceLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        originalPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(totalPriceLabel.snp.bottom).offset(2)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 先绑定购物车商品数据，确保cartItems是最新的
        viewModel.cartItems
            .subscribe(onNext: { [weak self] items in
                self?.cartItems = items
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 绑定空状态
        viewModel.isEmpty
            .subscribe(onNext: { [weak self] isEmpty in
                self?.emptyView.isHidden = !isEmpty
                self?.bottomContainer.isHidden = isEmpty
            })
            .disposed(by: disposeBag)

        // 后绑定统计信息，此时cartItems已经是最新的
        viewModel.cartSummary
            .subscribe(onNext: { [weak self] summary in
                self?.updateSummary(summary)
            })
            .disposed(by: disposeBag)

        // 绑定全选按钮
        selectAllButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 根据按钮当前状态决定操作：如果按钮是选中状态，说明要取消全选；否则要全选
                let action: CartAction = self.selectAllButton.isSelected ? .deselectAll : .selectAll
                self.viewModel.performAction(action)
            })
            .disposed(by: disposeBag)

        // 绑定结算按钮
        checkoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.checkout()
            })
            .disposed(by: disposeBag)

        // 绑定错误消息
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 辅助方法

    private func updateSummary(_ summary: CartSummary) {
        totalPriceLabel.text = summary.totalPriceString

        if let discountString = summary.totalDiscountString {
            originalPriceLabel.isHidden = false
            let originalTotal = summary.totalPrice + (summary.totalDiscount ?? 0)
            originalPriceLabel.attributedText = NSAttributedString(
                string: String(format: "¥%.2f", originalTotal),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            originalPriceLabel.isHidden = true
        }

        // 更新全选按钮状态 - 使用summary数据避免时序问题
        // 如果总商品数等于选中商品数，且总商品数大于0，则为全选状态
        let allSelected = summary.totalItems > 0 && summary.totalItems == summary.selectedItems
        selectAllButton.isSelected = allSelected

        // 更新结算按钮状态
        checkoutButton.isEnabled = summary.selectedItems > 0
        checkoutButton.backgroundColor = summary.selectedItems > 0 ? AppTheme.Color.primary : AppTheme.Color.textTertiary

        let buttonTitle = summary.selectedItems > 0 ? "结算(\(summary.selectedItems))" : "结算"
        checkoutButton.setTitle(buttonTitle, for: .normal)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as! CartItemCell
        let item = cartItems[indexPath.row]

        cell.configure(with: item)

        // 设置回调
        cell.onSelectToggle = { [weak self] isSelected in
            let action: CartAction = isSelected ? .selectItem(item.id) : .deselectItem(item.id)
            self?.viewModel.performAction(action)
        }

        cell.onQuantityIncrease = { [weak self] in
            self?.viewModel.performAction(.increaseQuantity(item.id))
        }

        cell.onQuantityDecrease = { [weak self] in
            self?.viewModel.performAction(.decreaseQuantity(item.id))
        }

        cell.onDelete = { [weak self] in
            self?.showDeleteConfirmation(for: item)
        }

        return cell
    }

    private func showDeleteConfirmation(for item: CartItem) {
        let alert = UIAlertController(title: "删除商品", message: "确定要删除这件商品吗？", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.viewModel.performAction(.removeItem(item.id))
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
