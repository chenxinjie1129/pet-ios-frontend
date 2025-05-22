//
//  MockImageGenerator.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit

/// 模拟图片生成器，用于开发阶段生成占位图片
class MockImageGenerator {

    /// 生成纯色图片
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片尺寸
    /// - Returns: 生成的图片
    static func generateImage(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    /// 生成带文字的图片
    /// - Parameters:
    ///   - text: 显示的文字
    ///   - backgroundColor: 背景颜色
    ///   - textColor: 文字颜色
    ///   - size: 图片尺寸
    /// - Returns: 生成的图片
    static func generateImage(text: String, backgroundColor: UIColor, textColor: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        // 绘制背景
        backgroundColor.setFill()
        UIRectFill(rect)

        // 绘制文字
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: textColor
        ]

        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    /// 生成模拟的轮播图图片
    /// - Parameter index: 图片索引
    /// - Returns: 生成的图片
    static func generateBannerImage(index: Int) -> UIImage {
        let colors: [UIColor] = [
            UIColor(hex: "#FF9500"),
            UIColor(hex: "#4CD964"),
            UIColor(hex: "#5AC8FA")
        ]

        let texts = [
            "宠物健康月，免费体检",
            "新品狗粮上市",
            "猫咪美容特惠"
        ]

        let colorIndex = index % colors.count
        return generateImage(
            text: texts[colorIndex],
            backgroundColor: colors[colorIndex],
            textColor: .white,
            size: CGSize(width: 350, height: 180)
        )
    }

    /// 生成模拟的知识图片
    /// - Parameter index: 图片索引
    /// - Returns: 生成的图片
    static func generateKnowledgeImage(index: Int) -> UIImage {
        let colors: [UIColor] = [
            UIColor(hex: "#FF9500"),
            UIColor(hex: "#4CD964"),
            UIColor(hex: "#5AC8FA")
        ]

        let texts = [
            "猫咪洗澡指南",
            "狗狗饮食禁忌",
            "新手养宠指南"
        ]

        let colorIndex = index % colors.count
        return generateImage(
            text: texts[colorIndex],
            backgroundColor: colors[colorIndex],
            textColor: .white,
            size: CGSize(width: 80, height: 80)
        )
    }


}
