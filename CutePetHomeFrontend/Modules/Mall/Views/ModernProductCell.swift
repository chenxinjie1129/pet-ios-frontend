//
//  ModernProductCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher

class ModernProductCell: UICollectionViewCell {
    
    // MARK: - UI组件
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppTheme.Color.background
        return imageView
    }()
    
    private let discountBadge: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 10, weight: .bold)
        label.textColor = .white
        label.backgroundColor = AppTheme.Color.accent
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = AppTheme.Color.accent
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14, weight: .medium)
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
    
    private let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = AppTheme.Color.primary
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - 属性
    
    static let reuseIdentifier = "ModernProductCell"
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRatingStars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(productImageView)
        containerView.addSubview(discountBadge)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(originalPriceLabel)
        containerView.addSubview(ratingStackView)
        containerView.addSubview(addToCartButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        productImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(containerView.snp.width).multipliedBy(0.75)
        }
        
        discountBadge.snp.makeConstraints { make in
            make.top.equalTo(productImageView).offset(8)
            make.left.equalTo(productImageView).offset(8)
            make.width.equalTo(40)
            make.height.equalTo(16)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(productImageView).offset(8)
            make.right.equalTo(productImageView).offset(-8)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }
        
        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(60)
            make.height.equalTo(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingStackView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
        }
        
        originalPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(8)
        }
        
        addToCartButton.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        // 添加按钮事件
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    private func setupRatingStars() {
        for _ in 0..<5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = UIColor.systemYellow
            starImageView.contentMode = .scaleAspectFit
            ratingStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - 配置方法
    
    func configure(title: String, price: String, originalPrice: String?, imageUrl: String) {
        titleLabel.text = title
        priceLabel.text = price
        
        // 设置原价和折扣
        if let originalPrice = originalPrice {
            originalPriceLabel.isHidden = false
            originalPriceLabel.attributedText = NSAttributedString(
                string: originalPrice,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            
            // 显示折扣标签
            discountBadge.isHidden = false
            discountBadge.text = "特价"
        } else {
            originalPriceLabel.isHidden = true
            discountBadge.isHidden = true
        }
        
        // 设置图片
        if let url = URL(string: imageUrl) {
            productImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        }
        
        // 随机设置评分
        updateRating(Double.random(in: 3.5...5.0))
    }
    
    private func updateRating(_ rating: Double) {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        for (index, starView) in ratingStackView.arrangedSubviews.enumerated() {
            guard let starImageView = starView as? UIImageView else { continue }
            
            if index < fullStars {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = UIColor.systemYellow
            } else if index == fullStars && hasHalfStar {
                starImageView.image = UIImage(systemName: "star.leadinghalf.filled")
                starImageView.tintColor = UIColor.systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = UIColor.lightGray
            }
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func favoriteButtonTapped() {
        favoriteButton.isSelected.toggle()
        
        UIView.animate(withDuration: 0.2) {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func addToCartButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addToCartButton.transform = CGAffineTransform.identity
            }
        }
        
        print("添加到购物车: \(titleLabel.text ?? "")")
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
        originalPriceLabel.text = nil
        originalPriceLabel.isHidden = true
        discountBadge.isHidden = true
        favoriteButton.isSelected = false
    }
}
