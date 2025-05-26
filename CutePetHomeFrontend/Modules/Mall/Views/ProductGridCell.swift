//
//  ProductGridCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher

class ProductGridCell: UICollectionViewCell {

    // MARK: - UI组件

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.08
        return view
    }()

    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppTheme.Color.background
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let discountBadge: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 10, weight: .bold)
        label.textColor = .white
        label.backgroundColor = AppTheme.Color.accent
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 13, weight: .medium)
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 15, weight: .bold)
        label.textColor = AppTheme.Color.accent
        return label
    }()

    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 11)
        label.textColor = AppTheme.Color.textTertiary
        label.isHidden = true
        return label
    }()

    private let salesLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 10)
        label.textColor = AppTheme.Color.textTertiary
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = AppTheme.Color.primary
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.1
        return button
    }()

    // MARK: - 属性

    static let reuseIdentifier = "ProductGridCell"

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(productImageView)
        containerView.addSubview(discountBadge)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(originalPriceLabel)
        containerView.addSubview(salesLabel)
        containerView.addSubview(addButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }

        productImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(productImageView.snp.width).multipliedBy(0.8)
        }

        discountBadge.snp.makeConstraints { make in
            make.top.equalTo(productImageView).offset(6)
            make.left.equalTo(productImageView).offset(6)
            make.width.equalTo(30)
            make.height.equalTo(16)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(8)
        }

        originalPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(8)
        }

        salesLabel.snp.makeConstraints { make in
            make.top.equalTo(originalPriceLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }

        // 添加按钮事件
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    // MARK: - 配置方法

    func configure(with product: ProductModel) {
        nameLabel.text = product.name
        priceLabel.text = product.priceString
        salesLabel.text = product.salesString

        // 设置原价和折扣
        if let originalPrice = product.originalPriceString {
            originalPriceLabel.isHidden = false
            originalPriceLabel.attributedText = NSAttributedString(
                string: originalPrice,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )

            // 显示折扣标签
            if let discount = product.discountPercentage {
                discountBadge.isHidden = false
                discountBadge.text = "-\(discount)%"
            }

            // 重新设置销量标签位置（有原价时）
            salesLabel.snp.remakeConstraints { make in
                make.top.equalTo(originalPriceLabel.snp.bottom).offset(4)
                make.left.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
            }
        } else {
            originalPriceLabel.isHidden = true
            discountBadge.isHidden = true

            // 重新设置销量标签位置（无原价时）
            salesLabel.snp.remakeConstraints { make in
                make.top.equalTo(priceLabel.snp.bottom).offset(4)
                make.left.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
            }
        }

        // 设置图片
        if let url = URL(string: product.imageUrl) {
            productImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        }
    }

    // MARK: - 事件处理

    @objc private func addButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = CGAffineTransform.identity
            }
        }

        print("添加到购物车: \(nameLabel.text ?? "")")
    }

    // MARK: - 重用准备

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
        nameLabel.text = nil
        priceLabel.text = nil
        originalPriceLabel.text = nil
        originalPriceLabel.isHidden = true
        salesLabel.text = nil
        discountBadge.isHidden = true
    }
}
