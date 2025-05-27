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
    let sort: Int?
    let icon: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, sort, icon, status
    }
}

/// 商品模型
struct Product: Codable {
    let id: Int64
    let name: String
    let categoryId: Int64
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
    var quantity: Int
    let createTime: String?
    let updateTime: String?

    // 关联的商品信息
    var product: Product?

    // UI状态属性（不参与编码）
    var isSelected: Bool = true
    var maxQuantity: Int = 10

    // 计算属性：小计金额
    var subtotal: Double {
        guard let product = product else { return 0 }
        return product.price * Double(quantity)
    }

    // 计算属性：价格字符串
    var priceString: String {
        guard let product = product else { return "¥0.00" }
        return String(format: "¥%.2f", product.price)
    }

    // 计算属性：总价字符串
    var totalPriceString: String {
        return String(format: "¥%.2f", subtotal)
    }

    // 计算属性：原价字符串
    var originalPriceString: String? {
        guard let product = product, let originalPrice = product.originalPrice else { return nil }
        return String(format: "¥%.2f", originalPrice)
    }

    // 计算属性：商品名称
    var name: String {
        return product?.name ?? ""
    }

    // 计算属性：商品图片
    var imageUrl: String {
        return product?.mainImage ?? ""
    }

    // 计算属性：是否有折扣
    var hasDiscount: Bool {
        return product?.hasDiscount ?? false
    }

    // 计算属性：折扣百分比
    var discountPercentage: Int? {
        return product?.discountPercentage
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

// MARK: - 购物车扩展模型

/// 购物车统计模型
struct CartSummary {
    let totalItems: Int
    let selectedItems: Int
    let totalPrice: Double
    let totalOriginalPrice: Double?
    let totalDiscount: Double?

    var totalPriceString: String {
        return String(format: "¥%.2f", totalPrice)
    }

    var totalDiscountString: String? {
        guard let discount = totalDiscount, discount > 0 else { return nil }
        return String(format: "¥%.2f", discount)
    }

    var hasDiscount: Bool {
        return totalDiscount != nil && totalDiscount! > 0
    }
}

/// 购物车操作类型
enum CartAction {
    case selectItem(Int)
    case deselectItem(Int)
    case selectAll
    case deselectAll
    case increaseQuantity(Int)
    case decreaseQuantity(Int)
    case removeItem(Int)
    case clearCart
}

// MARK: - 商城扩展模型

/// 简化的分类模型（用于UI显示）
struct CategoryModel {
    let id: Int
    let name: String
    let icon: String

    // 从ProductCategory转换
    init(from category: ProductCategory) {
        self.id = category.id
        self.name = category.name
        self.icon = category.icon ?? "square.grid.2x2"
    }

    // 直接初始化
    init(id: Int, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

/// 简化的商品模型（用于UI显示）
struct ProductModel {
    let id: Int
    let name: String
    let price: Double
    let originalPrice: Double?
    let imageUrl: String
    let sales: Int

    // 从Product转换
    init(from product: Product) {
        self.id = Int(product.id)
        self.name = product.name
        self.price = product.price
        self.originalPrice = product.originalPrice
        self.imageUrl = product.mainImage ?? ""
        self.sales = product.sales ?? 0
    }

    // 直接初始化
    init(id: Int, name: String, price: Double, originalPrice: Double?, imageUrl: String, sales: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.originalPrice = originalPrice
        self.imageUrl = imageUrl
        self.sales = sales
    }

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
