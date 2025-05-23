//
//  CategoryCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit

class CategoryCell: UICollectionViewCell {
    
    // MARK: - UI组件
    
    // 分类图标
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppTheme.Color.textPrimary
        return imageView
    }()
    
    // 分类名称
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14)
        label.textColor = AppTheme.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    // 选中指示器
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primary
        view.isHidden = true
        return view
    }()
    
    // MARK: - 属性
    
    static let reuseIdentifier = "CategoryCell"
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
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
        // 设置单元格背景
        contentView.backgroundColor = .white
        
        // 添加子视图
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(selectionIndicator)
        
        // 设置约束
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        selectionIndicator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(2)
        }
    }
    
    // MARK: - 配置方法
    
    func configure(with category: ProductCategory) {
        // 设置分类名称
        nameLabel.text = category.name
        
        // 设置图标
        if let iconName = category.icon {
            if iconName.hasPrefix("http") {
                // 如果是URL，使用Kingfisher加载
                if let url = URL(string: iconName) {
                    iconImageView.kf.setImage(
                        with: url,
                        placeholder: UIImage(systemName: "tag"),
                        options: [.transition(.fade(0.2))]
                    )
                }
            } else {
                // 如果是系统图标名称
                iconImageView.image = UIImage(systemName: iconName) ?? UIImage(systemName: "tag")
            }
        } else {
            // 默认图标
            iconImageView.image = UIImage(systemName: "tag")
        }
        
        // 更新选中状态
        updateSelectionState()
    }
    
    // MARK: - 辅助方法
    
    private func updateSelectionState() {
        if isSelected {
            // 选中状态
            nameLabel.textColor = AppTheme.Color.primary
            nameLabel.font = AppTheme.Font.body(size: 14, weight: .medium)
            iconImageView.tintColor = AppTheme.Color.primary
            selectionIndicator.isHidden = false
            contentView.backgroundColor = AppTheme.Color.background.withAlphaComponent(0.5)
        } else {
            // 未选中状态
            nameLabel.textColor = AppTheme.Color.textPrimary
            nameLabel.font = AppTheme.Font.body(size: 14)
            iconImageView.tintColor = AppTheme.Color.textPrimary
            selectionIndicator.isHidden = true
            contentView.backgroundColor = .white
        }
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置图标
        iconImageView.image = nil
        
        // 重置标签
        nameLabel.text = nil
        
        // 重置选中状态
        selectionIndicator.isHidden = true
        contentView.backgroundColor = .white
    }
}
