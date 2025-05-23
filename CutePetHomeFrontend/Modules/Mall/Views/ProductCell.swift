//
//  ProductCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher

class ProductCell: UICollectionViewCell {
    
    // MARK: - UI组件
    
    // 商品图片
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppTheme.Color.background
        imageView.layer.cornerRadius = AppTheme.Metrics.cornerRadiusSmall
        return imageView
    }()
    
    // 商品名称
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14)
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 2
        return label
    }()
    
    // 商品价格
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 16, weight: .medium)
        label.textColor = AppTheme.Color.accent
        return label
    }()
    
    // 商品原价
    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textTertiary
        
        // 添加删除线
        let attributeString = NSMutableAttributedString(string: "")
        attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        label.attributedText = attributeString
        
        return label
    }()
    
    // 折扣标签
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = .white
        label.backgroundColor = AppTheme.Color.accent
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    // 销量标签
    private let salesLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textTertiary
        return label
    }()
    
    // 加入购物车按钮
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        button.tintColor = AppTheme.Color.primary
        button.backgroundColor = AppTheme.Color.background
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.Color.border.cgColor
        return button
    }()
    
    // MARK: - 属性
    
    static let reuseIdentifier = "ProductCell"
    
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
        // 设置单元格背景和边框
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = AppTheme.Metrics.cornerRadiusMedium
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = AppTheme.Color.border.cgColor
        contentView.clipsToBounds = true
        
        // 添加阴影
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
        
        // 添加子视图
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(originalPriceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(salesLabel)
        contentView.addSubview(addToCartButton)
        
        // 设置约束
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(contentView.snp.width) // 正方形图片
        }
        
        discountLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(8)
            make.right.equalTo(imageView).offset(-8)
            make.width.equalTo(40)
            make.height.equalTo(16)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(8)
        }
        
        originalPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(8)
        }
        
        salesLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        addToCartButton.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(30)
        }
        
        // 添加按钮点击事件
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - 配置方法
    
    func configure(with product: Product) {
        // 设置商品名称
        nameLabel.text = product.name
        
        // 设置商品价格
        priceLabel.text = "¥\(String(format: "%.2f", product.price))"
        
        // 设置原价和折扣
        if let originalPrice = product.originalPrice, originalPrice > product.price {
            originalPriceLabel.isHidden = false
            originalPriceLabel.text = "¥\(String(format: "%.2f", originalPrice))"
            
            // 设置删除线
            let attributeString = NSMutableAttributedString(string: originalPriceLabel.text ?? "")
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
            originalPriceLabel.attributedText = attributeString
            
            // 显示折扣标签
            if let discount = product.discountPercentage {
                discountLabel.isHidden = false
                discountLabel.text = "\(discount)%"
            } else {
                discountLabel.isHidden = true
            }
        } else {
            originalPriceLabel.isHidden = true
            discountLabel.isHidden = true
        }
        
        // 设置销量
        if let sales = product.sales {
            salesLabel.text = "销量: \(sales)"
        } else {
            salesLabel.text = "新品"
        }
        
        // 设置图片
        if let imageUrl = product.mainImage, !imageUrl.isEmpty {
            let url = URL(string: imageUrl)
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            // 使用占位图
            imageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func addToCartButtonTapped() {
        // 添加到购物车的动画
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToCartButton.transform = CGAffineTransform.identity
            }
        }
        
        // 通知代理或使用闭包回调
        // 这里可以添加回调逻辑
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置图片
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        
        // 重置标签
        nameLabel.text = nil
        priceLabel.text = nil
        originalPriceLabel.text = nil
        salesLabel.text = nil
        
        // 隐藏折扣标签
        discountLabel.isHidden = true
    }
}
