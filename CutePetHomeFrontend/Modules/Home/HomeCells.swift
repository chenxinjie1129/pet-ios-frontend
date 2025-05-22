//
//  HomeCells.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - 养宠知识单元格

class KnowledgeCell: UITableViewCell {

    // 标题标签
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(weight: .medium)
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 2
        return label
    }()

    // 摘要标签
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textSecondary
        label.numberOfLines = 2
        return label
    }()

    // 作者标签
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textTertiary
        return label
    }()

    // 阅读量标签
    private let readCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textTertiary
        return label
    }()

    // 封面图片
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = AppTheme.Metrics.cornerRadiusSmall
        return imageView
    }()

    // 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置UI
    private func setupUI() {
        selectionStyle = .none

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(readCountLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
            make.width.equalTo(80)
            make.height.equalTo(80)
            make.bottom.lessThanOrEqualToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalTo(coverImageView.snp.left).offset(-AppTheme.Metrics.spacingMedium)
        }

        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppTheme.Metrics.spacingSmall)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }

        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(AppTheme.Metrics.spacingSmall)
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }

        readCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(authorLabel)
            make.right.equalTo(titleLabel)
        }
    }

    // 配置单元格
    func configure(with item: KnowledgeItem) {
        titleLabel.text = item.title
        summaryLabel.text = item.summary
        authorLabel.text = item.author
        readCountLabel.text = "\(item.readCount)阅读"

        // 设置图片（从Kingfisher缓存加载）
        coverImageView.kf.setImage(with: URL(string: item.imageUrl),
                                  placeholder: UIImage(systemName: "photo"),
                                  options: [.cacheMemoryOnly])
    }
}
