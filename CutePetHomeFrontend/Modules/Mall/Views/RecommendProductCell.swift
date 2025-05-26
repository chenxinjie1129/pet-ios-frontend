//
//  RecommendProductCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher

class RecommendProductCell: UICollectionViewCell {
    
    // MARK: - UI组件
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = AppTheme.Color.background
        return imageView
    }()
    
    private let hotBadge: UILabel = {
        let label = UILabel()
        label.text = "🔥"
        label.font = AppTheme.Font.body(size: 12)
        label.backgroundColor = UIColor.red
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
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
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = AppTheme.Color.primary
        button.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - 属性
    
    static let reuseIdentifier = "RecommendProductCell"
    
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
        containerView.addSubview(hotBadge)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(addButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        productImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(100)
        }
        
        hotBadge.snp.makeConstraints { make in
            make.top.equalTo(productImageView).offset(6)
            make.left.equalTo(productImageView).offset(6)
            make.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(8)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        // 添加点击动画
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - 配置方法
    
    func configure(title: String, price: String, imageUrl: String) {
        titleLabel.text = title
        priceLabel.text = price
        
        if let url = URL(string: imageUrl) {
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
        
        // 这里可以添加加入购物车的逻辑
        print("添加到购物车: \(titleLabel.text ?? "")")
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
        titleLabel.text = nil
        priceLabel.text = nil
    }
}
