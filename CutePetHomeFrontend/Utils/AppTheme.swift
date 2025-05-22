//
//  AppTheme.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit

/// 应用主题管理类，统一管理应用的颜色、字体等样式
struct AppTheme {
    
    // MARK: - 颜色
    
    struct Color {
        // 主色调
        static let primary = UIColor(hex: "#FF9500") // 橙色
        static let secondary = UIColor(hex: "#4CD964") // 绿色
        
        // 辅助色
        static let accent = UIColor(hex: "#FF2D55") // 强调色（红色）
        
        // 文本颜色
        static let textPrimary = UIColor(hex: "#333333") // 主文本
        static let textSecondary = UIColor(hex: "#666666") // 次要文本
        static let textTertiary = UIColor(hex: "#999999") // 辅助文本
        
        // 背景色
        static let background = UIColor(hex: "#F8F8F8") // 主背景
        static let cardBackground = UIColor.white // 卡片背景
        
        // 边框和分割线
        static let border = UIColor(hex: "#EEEEEE")
        static let separator = UIColor(hex: "#E5E5E5")
        
        // 状态颜色
        static let success = UIColor(hex: "#4CD964") // 成功
        static let warning = UIColor(hex: "#FFCC00") // 警告
        static let error = UIColor(hex: "#FF3B30") // 错误
        static let info = UIColor(hex: "#5AC8FA") // 信息
    }
    
    // MARK: - 字体
    
    struct Font {
        // 标题字体
        static func title1() -> UIFont {
            return UIFont.systemFont(ofSize: 28, weight: .bold)
        }
        
        static func title2() -> UIFont {
            return UIFont.systemFont(ofSize: 22, weight: .bold)
        }
        
        static func title3() -> UIFont {
            return UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
        
        // 正文字体
        static func body(size: CGFloat = 16, weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        // 小字体
        static func footnote() -> UIFont {
            return UIFont.systemFont(ofSize: 13, weight: .regular)
        }
        
        // 按钮字体
        static func button() -> UIFont {
            return UIFont.systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    // MARK: - 尺寸
    
    struct Metrics {
        // 通用间距
        static let spacingTiny: CGFloat = 4
        static let spacingSmall: CGFloat = 8
        static let spacingMedium: CGFloat = 16
        static let spacingLarge: CGFloat = 24
        static let spacingExtraLarge: CGFloat = 32
        
        // 圆角
        static let cornerRadiusSmall: CGFloat = 4
        static let cornerRadiusMedium: CGFloat = 8
        static let cornerRadiusLarge: CGFloat = 16
        
        // 按钮高度
        static let buttonHeightSmall: CGFloat = 36
        static let buttonHeightMedium: CGFloat = 44
        static let buttonHeightLarge: CGFloat = 52
        
        // 输入框高度
        static let textFieldHeight: CGFloat = 48
    }
    
    // MARK: - 动画
    
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let slowDuration: TimeInterval = 0.5
    }
}

// MARK: - UIColor 扩展，支持十六进制颜色

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
