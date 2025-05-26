//
//  MallModels.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation

// MARK: - 分类模型

struct CategoryModel {
    let id: Int
    let name: String
    let icon: String
}

// MARK: - 商品模型

struct ProductModel {
    let id: Int
    let name: String
    let price: Double
    let originalPrice: Double?
    let imageUrl: String
    let sales: Int
    
    var priceString: String {
        return String(format: "¥%.2f", price)
    }
    
    var originalPriceString: String? {
        guard let originalPrice = originalPrice else { return nil }
        return String(format: "¥%.2f", originalPrice)
    }
    
    var salesString: String {
        if sales > 1000 {
            return "销量\(sales/1000)k+"
        } else {
            return "销量\(sales)"
        }
    }
    
    var hasDiscount: Bool {
        return originalPrice != nil && originalPrice! > price
    }
    
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        let discount = (originalPrice - price) / originalPrice * 100
        return Int(discount)
    }
}
