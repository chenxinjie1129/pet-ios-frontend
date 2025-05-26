//
//  CategoryTableCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit

class CategoryTableCell: UITableViewCell {

    // MARK: - UI组件

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppTheme.Color.textSecondary
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14, weight: .medium)
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

    static let reuseIdentifier = "CategoryTableCell"

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(selectionIndicator)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(18)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().offset(-6)
        }

        selectionIndicator.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(3)
            make.height.equalTo(20)
        }
    }

    // MARK: - 配置方法

    func configure(with category: CategoryModel, isSelected: Bool) {
        nameLabel.text = category.name
        iconImageView.image = UIImage(systemName: category.icon)

        updateSelectionState(isSelected: isSelected)
    }

    // MARK: - 辅助方法

    private func updateSelectionState(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.containerView.backgroundColor = AppTheme.Color.primary.withAlphaComponent(0.1)
                self.iconImageView.tintColor = AppTheme.Color.primary
                self.nameLabel.textColor = AppTheme.Color.primary
                self.nameLabel.font = AppTheme.Font.body(size: 14, weight: .semibold)
                self.selectionIndicator.isHidden = false
            } else {
                self.containerView.backgroundColor = .clear
                self.iconImageView.tintColor = AppTheme.Color.textSecondary
                self.nameLabel.textColor = AppTheme.Color.textPrimary
                self.nameLabel.font = AppTheme.Font.body(size: 14, weight: .medium)
                self.selectionIndicator.isHidden = true
            }
        }
    }

    // MARK: - 重用准备

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        iconImageView.image = nil
        updateSelectionState(isSelected: false)
    }
}
