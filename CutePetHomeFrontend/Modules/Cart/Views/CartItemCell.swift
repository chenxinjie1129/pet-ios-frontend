//
//  CartItemCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

class CartItemCell: UITableViewCell {

    // MARK: - UI组件

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.05
        return view
    }()

    private let selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.tintColor = AppTheme.Color.primary
        return button
    }()

    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = AppTheme.Color.background
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 15, weight: .medium)
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 16, weight: .bold)
        label.textColor = AppTheme.Color.accent
        return label
    }()

    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 12)
        label.textColor = AppTheme.Color.textTertiary
        label.isHidden = true
        return label
    }()

    private let quantityContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.Color.border.cgColor
        return view
    }()

    private let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.tintColor = AppTheme.Color.textSecondary
        button.backgroundColor = .clear
        return button
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14, weight: .medium)
        label.textColor = AppTheme.Color.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = AppTheme.Color.primary
        button.backgroundColor = .clear
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = AppTheme.Color.textTertiary
        return button
    }()

    // MARK: - 属性

    static let reuseIdentifier = "CartItemCell"
    private var disposeBag = DisposeBag()

    // 回调闭包
    var onSelectToggle: ((Bool) -> Void)?
    var onQuantityIncrease: (() -> Void)?
    var onQuantityDecrease: (() -> Void)?
    var onDelete: (() -> Void)?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // 设置可访问性
        isAccessibilityElement = false
        contentView.isAccessibilityElement = false
        containerView.isAccessibilityElement = false

        contentView.addSubview(containerView)
        containerView.addSubview(selectButton)
        containerView.addSubview(productImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(originalPriceLabel)
        containerView.addSubview(quantityContainerView)
        containerView.addSubview(deleteButton)

        quantityContainerView.addSubview(decreaseButton)
        quantityContainerView.addSubview(quantityLabel)
        quantityContainerView.addSubview(increaseButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            make.height.equalTo(112) // 固定高度
        }

        selectButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        productImageView.snp.makeConstraints { make in
            make.left.equalTo(selectButton.snp.right).offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(80)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(productImageView.snp.right).offset(12)
            make.top.equalTo(productImageView)
            make.right.equalTo(deleteButton.snp.left).offset(-8)
        }

        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }

        originalPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(8)
            make.centerY.equalTo(priceLabel)
        }

        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }

        quantityContainerView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(100)
            make.height.equalTo(32)
        }

        decreaseButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        quantityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(36)
        }

        increaseButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }

    private func setupBindings() {
        selectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.selectButton.isSelected.toggle()
                self.onSelectToggle?(self.selectButton.isSelected)
            })
            .disposed(by: disposeBag)

        increaseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onQuantityIncrease?()
            })
            .disposed(by: disposeBag)

        decreaseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onQuantityDecrease?()
            })
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onDelete?()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 配置方法

    func configure(with item: CartItem) {
        selectButton.isSelected = item.isSelected
        nameLabel.text = item.name
        priceLabel.text = item.priceString
        quantityLabel.text = "\(item.quantity)"

        // 设置原价
        if let originalPrice = item.originalPriceString {
            originalPriceLabel.isHidden = false
            originalPriceLabel.attributedText = NSAttributedString(
                string: originalPrice,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            originalPriceLabel.isHidden = true
        }

        // 设置数量按钮状态
        decreaseButton.isEnabled = item.quantity > 1
        decreaseButton.tintColor = item.quantity > 1 ? AppTheme.Color.textSecondary : AppTheme.Color.textTertiary

        increaseButton.isEnabled = item.quantity < item.maxQuantity
        increaseButton.tintColor = item.quantity < item.maxQuantity ? AppTheme.Color.primary : AppTheme.Color.textTertiary

        // 设置图片
        if let url = URL(string: item.imageUrl) {
            productImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        }

        // 设置可访问性标签
        selectButton.accessibilityLabel = item.isSelected ? "已选择" : "未选择"
        nameLabel.accessibilityLabel = "商品名称: \(item.name)"
        priceLabel.accessibilityLabel = "价格: \(item.priceString)"
        quantityLabel.accessibilityLabel = "数量: \(item.quantity)"
        decreaseButton.accessibilityLabel = "减少数量"
        increaseButton.accessibilityLabel = "增加数量"
        deleteButton.accessibilityLabel = "删除商品"

        if let originalPrice = item.originalPriceString {
            originalPriceLabel.accessibilityLabel = "原价: \(originalPrice)"
        }
    }

    // MARK: - 重用准备

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        setupBindings()

        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        originalPriceLabel.text = nil
        originalPriceLabel.isHidden = true
        quantityLabel.text = nil
        selectButton.isSelected = false

        onSelectToggle = nil
        onQuantityIncrease = nil
        onQuantityDecrease = nil
        onDelete = nil
    }
}
