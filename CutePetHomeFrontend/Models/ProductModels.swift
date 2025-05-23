//
//  ProductModels.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation

/// 商品分类模型
struct ProductCategory: Codable {
    let id: Int
    let name: String
    let parentId: Int?
    let level: Int?
    let sort: Int?
    let icon: String?
    let status: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, level, sort, icon, status
        case parentId = "parentId"
    }
}

/// 商品模型
struct Product: Codable {
    let id: Int
    let name: String
    let categoryId: Int
    let brand: String?
    let price: Double
    let originalPrice: Double?
    let stock: Int?
    let sales: Int?
    let mainImage: String?
    let album: String?
    let description: String?
    let detail: String?
    let status: Int?
    let createTime: String?
    let updateTime: String?
    
    // 计算属性：是否有折扣
    var hasDiscount: Bool {
        guard let originalPrice = originalPrice else { return false }
        return originalPrice > price
    }
    
    // 计算属性：折扣百分比
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > 0, hasDiscount else { return nil }
        let discount = (1 - (price / originalPrice)) * 100
        return Int(discount)
    }
    
    // 计算属性：相册图片数组
    var albumImages: [String] {
        guard let album = album else { return [] }
        return album.components(separatedBy: ",")
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, brand, price, stock, sales, description, detail, status
        case categoryId = "categoryId"
        case originalPrice = "originalPrice"
        case mainImage = "mainImage"
        case album
        case createTime = "createTime"
        case updateTime = "updateTime"
    }
}

/// 购物车项模型
struct CartItem: Codable {
    let id: Int
    let userId: Int
    let productId: Int
    let quantity: Int
    let createTime: String?
    let updateTime: String?
    
    // 关联的商品信息
    var product: Product?
    
    // 计算属性：小计金额
    var subtotal: Double {
        guard let product = product else { return 0 }
        return product.price * Double(quantity)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case userId = "userId"
        case productId = "productId"
        case product
        case createTime = "createTime"
        case updateTime = "updateTime"
    }
}

/// 商品列表响应
struct ProductListResponse: Codable {
    let products: [Product]
    let pagination: Pagination
}

/// 分类列表响应
struct CategoryListResponse: Codable {
    let categories: [ProductCategory]
}

/// 购物车列表响应
struct CartListResponse: Codable {
    let cartItems: [CartItem]
    let totalAmount: Double
    let totalQuantity: Int
}
