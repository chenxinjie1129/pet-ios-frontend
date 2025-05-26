//
//  BannerCell.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import Kingfisher
import FSPagerView

class BannerCell: FSPagerViewCell {
    
    // MARK: - UI组件
    
    private let bannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = AppTheme.Color.background
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        layer.locations = [0.6, 1.0]
        return layer
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body(size: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
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
        contentView.addSubview(bannerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        bannerImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(bannerImageView).offset(16)
            make.right.equalTo(bannerImageView).offset(-16)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(bannerImageView).offset(16)
            make.right.equalTo(bannerImageView).offset(-16)
            make.bottom.equalTo(bannerImageView).offset(-16)
        }
        
        // 添加渐变层
        bannerImageView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bannerImageView.bounds
    }
    
    // MARK: - 配置方法
    
    func configure(with imageUrl: String) {
        // 设置图片
        if let url = URL(string: imageUrl) {
            bannerImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.3))]
            )
        }
        
        // 设置标题和副标题
        let titles = [
            ("宠物健康月", "免费体检活动进行中"),
            ("新品狗粮上市", "营养均衡，健康美味"),
            ("猫咪美容特惠", "专业美容师服务"),
            ("春季宠物用品", "全场8折优惠")
        ]
        
        let randomIndex = Int.random(in: 0..<titles.count)
        titleLabel.text = titles[randomIndex].0
        subtitleLabel.text = titles[randomIndex].1
    }
    
    // MARK: - 重用准备
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bannerImageView.kf.cancelDownloadTask()
        bannerImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
