//
//  ModernCategoryCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit

class ModernCategoryCell: UICollectionViewCell {
    
    // MARK: - UI组件
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppTheme.Color.textSecondary
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 12, weight: .medium)
        label.textColor = AppTheme.Color.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.primary
        view.layer.cornerRadius = 2
        view.isHidden = true
        return view
    }()
    
    // MARK: - 属性
    
    static let reuseIdentifier = "ModernCategoryCell"
    
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
        contentView.addSubview(iconContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(selectionIndicator)
        iconContainer.addSubview(iconImageView)
        
        iconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(4)
        }
        
        selectionIndicator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(3)
        }
    }
    
    // MARK: - 配置方法
    
    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        updateSelectionState()
    }
    
    // MARK: - 辅助方法
    
    private func updateSelectionState() {
        UIView.animate(withDuration: 0.2) {
            if self.isSelected {
                self.iconContainer.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.1)
                self.iconImageView.tintColor = AppTheme.Color.primary
                self.titleLabel.textColor = AppTheme.Color.primary
                self.titleLabel.font = AppTheme.Font.body(size: 12, weight: .semibold)
                self.selectionIndicator.isHidden = false
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                self.iconContainer.backgroundColor = AppTheme.Color.background
                self.iconImageView.tintColor = AppTheme.Color.textSecondary
                self.titleLabel.textColor = AppTheme.Color.textPrimary
                self.titleLabel.font = AppTheme.Font.body(size: 12, weight: .medium)
                self.selectionIndicator.isHidden = true
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
        isSelected = false
        transform = CGAffineTransform.identity
    }
}
