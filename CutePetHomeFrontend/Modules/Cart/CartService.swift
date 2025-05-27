//
//  CartService.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation
import RxSwift

class CartService {

    // 单例
    static let shared = CartService()

    private init() {}

    // MARK: - 购物车API调用

    /// 获取购物车列表
    func getCartItems() -> Observable<[CartItem]> {
        return NetworkManager.shared.request(PetAPI.getCartItems)
    }

    /// 添加商品到购物车
    func addToCart(productId: Int64, quantity: Int = 1) -> Observable<EmptyResponse> {
        return NetworkManager.shared.request(PetAPI.addToCart(productId: Int(productId), quantity: quantity))
    }

    /// 更新购物车商品数量
    func updateCartItem(itemId: Int, quantity: Int) -> Observable<EmptyResponse> {
        return NetworkManager.shared.request(PetAPI.updateCartItem(itemId: itemId, quantity: quantity))
    }

    /// 删除购物车商品
    func removeCartItem(itemId: Int) -> Observable<EmptyResponse> {
        return NetworkManager.shared.request(PetAPI.removeCartItem(itemId: itemId))
    }
}
