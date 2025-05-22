//
//  RoundedButton.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit

/// 自定义圆角按钮
class RoundedButton: UIButton {
    
    // MARK: - 按钮样式
    
    enum Style {
        case primary    // 主要按钮
        case secondary  // 次要按钮
        case outline    // 边框按钮
        case plain      // 纯文本按钮
    }
    
    // MARK: - 属性
    
    /// 按钮样式
    var buttonStyle: Style = .primary {
        didSet {
            updateAppearance()
        }
    }
    
    /// 圆角大小
    var cornerRadius: CGFloat = AppTheme.Metrics.cornerRadiusMedium {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    /// 是否启用阴影
    var enableShadow: Bool = false {
        didSet {
            updateShadow()
        }
    }
    
    // MARK: - 初始化方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    convenience init(style: Style, title: String) {
        self.init(frame: .zero)
        self.buttonStyle = style
        self.setTitle(title, for: .normal)
        updateAppearance()
    }
    
    // MARK: - 设置方法
    
    private func setupButton() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        titleLabel?.font = AppTheme.Font.button()
        updateAppearance()
    }
    
    private func updateAppearance() {
        switch buttonStyle {
        case .primary:
            backgroundColor = AppTheme.Color.primary
            setTitleColor(.white, for: .normal)
            setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            layer.borderWidth = 0
            
        case .secondary:
            backgroundColor = AppTheme.Color.secondary
            setTitleColor(.white, for: .normal)
            setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
            layer.borderWidth = 0
            
        case .outline:
            backgroundColor = .clear
            setTitleColor(AppTheme.Color.primary, for: .normal)
            setTitleColor(AppTheme.Color.primary.withAlphaComponent(0.7), for: .highlighted)
            layer.borderWidth = 1
            layer.borderColor = AppTheme.Color.primary.cgColor
            
        case .plain:
            backgroundColor = .clear
            setTitleColor(AppTheme.Color.primary, for: .normal)
            setTitleColor(AppTheme.Color.primary.withAlphaComponent(0.7), for: .highlighted)
            layer.borderWidth = 0
        }
        
        updateShadow()
    }
    
    private func updateShadow() {
        if enableShadow && buttonStyle != .plain && buttonStyle != .outline {
            clipsToBounds = false
            layer.shadowColor = AppTheme.Color.primary.withAlphaComponent(0.3).cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 4
        } else {
            clipsToBounds = true
            layer.shadowOpacity = 0
        }
    }
    
    // MARK: - 状态变化
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
}
