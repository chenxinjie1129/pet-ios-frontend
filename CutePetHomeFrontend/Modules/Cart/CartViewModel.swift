//
//  CartViewModel.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation
import RxSwift
import RxCocoa

class CartViewModel {

    // MARK: - 输出

    let cartItems = BehaviorRelay<[CartItem]>(value: [])
    let cartSummary = BehaviorRelay<CartSummary>(value: CartSummary(totalItems: 0, selectedItems: 0, totalPrice: 0, totalOriginalPrice: nil, totalDiscount: nil))
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let isEmpty = BehaviorRelay<Bool>(value: true)

    // MARK: - 私有属性

    private let disposeBag = DisposeBag()

    // MARK: - 初始化

    init() {
        setupBindings()
        loadCartData()
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 监听购物车商品变化，更新统计信息
        cartItems
            .map { [weak self] items in
                self?.calculateSummary(from: items) ?? CartSummary(totalItems: 0, selectedItems: 0, totalPrice: 0, totalOriginalPrice: nil, totalDiscount: nil)
            }
            .bind(to: cartSummary)
            .disposed(by: disposeBag)

        // 监听购物车是否为空
        cartItems
            .map { $0.isEmpty }
            .bind(to: isEmpty)
            .disposed(by: disposeBag)
    }

    // MARK: - 公共方法

    func performAction(_ action: CartAction) {
        var items = cartItems.value

        switch action {
        case .selectItem(let itemId):
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                items[index].isSelected = true
            }

        case .deselectItem(let itemId):
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                items[index].isSelected = false
            }

        case .selectAll:
            for i in 0..<items.count {
                items[i].isSelected = true
            }

        case .deselectAll:
            for i in 0..<items.count {
                items[i].isSelected = false
            }

        case .increaseQuantity(let itemId):
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                let item = items[index]
                if item.quantity < item.maxQuantity {
                    let newQuantity = item.quantity + 1
                    items[index].quantity = newQuantity

                    // 调用API更新数量
                    CartService.shared.updateCartItem(itemId: itemId, quantity: newQuantity)
                        .subscribe(
                            onNext: { _ in
                                // 更新成功，无需额外操作
                            },
                            onError: { [weak self] error in
                                // 更新失败，恢复原数量
                                items[index].quantity = item.quantity
                                self?.cartItems.accept(items)
                                self?.errorMessage.accept("更新失败: \(error.localizedDescription)")
                            }
                        )
                        .disposed(by: disposeBag)
                }
            }

        case .decreaseQuantity(let itemId):
            if let index = items.firstIndex(where: { $0.id == itemId }) {
                let item = items[index]
                if item.quantity > 1 {
                    let newQuantity = item.quantity - 1
                    items[index].quantity = newQuantity

                    // 调用API更新数量
                    CartService.shared.updateCartItem(itemId: itemId, quantity: newQuantity)
                        .subscribe(
                            onNext: { _ in
                                // 更新成功，无需额外操作
                            },
                            onError: { [weak self] error in
                                // 更新失败，恢复原数量
                                items[index].quantity = item.quantity
                                self?.cartItems.accept(items)
                                self?.errorMessage.accept("更新失败: \(error.localizedDescription)")
                            }
                        )
                        .disposed(by: disposeBag)
                }
            }

        case .removeItem(let itemId):
            // 先从本地移除
            items.removeAll { $0.id == itemId }

            // 调用API删除
            CartService.shared.removeCartItem(itemId: itemId)
                .subscribe(
                    onNext: { _ in
                        // 删除成功，无需额外操作
                    },
                    onError: { [weak self] error in
                        // 删除失败，重新加载购物车数据
                        self?.loadCartData()
                        self?.errorMessage.accept("删除失败: \(error.localizedDescription)")
                    }
                )
                .disposed(by: disposeBag)

        case .clearCart:
            items.removeAll()
        }

        cartItems.accept(items)
    }

    func checkout() {
        let selectedItems = cartItems.value.filter { $0.isSelected }
        if selectedItems.isEmpty {
            errorMessage.accept("请选择要结算的商品")
            return
        }

        // TODO: 实现结算逻辑
        print("结算商品: \(selectedItems.count) 件")
        errorMessage.accept("结算功能即将上线，敬请期待")
    }

    // MARK: - 私有方法

    private func calculateSummary(from items: [CartItem]) -> CartSummary {
        let selectedItems = items.filter { $0.isSelected }

        let totalItems = items.reduce(into: 0) { $0 += $1.quantity }
        let selectedItemsCount = selectedItems.reduce(into: 0) { $0 += $1.quantity }
        let totalPrice = selectedItems.reduce(into: 0.0) { $0 += $1.subtotal }

        let totalOriginalPrice = selectedItems.compactMap { item in
            guard let product = item.product, let originalPrice = product.originalPrice else { return nil }
            return originalPrice * Double(item.quantity)
        }.reduce(into: 0.0) { $0 += $1 }

        let totalDiscount = totalOriginalPrice > 0 ? totalOriginalPrice - totalPrice : nil

        return CartSummary(
            totalItems: totalItems,
            selectedItems: selectedItemsCount,
            totalPrice: totalPrice,
            totalOriginalPrice: totalOriginalPrice > 0 ? totalOriginalPrice : nil,
            totalDiscount: totalDiscount
        )
    }

    private func loadCartData() {
        isLoading.accept(true)

        CartService.shared.getCartItems()
            .subscribe(
                onNext: { [weak self] cartItems in
                    self?.isLoading.accept(false)
                    self?.cartItems.accept(cartItems)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept("获取购物车数据失败: \(error.localizedDescription)")
                    // 使用模拟数据作为备选
                    self?.loadMockData()
                }
            )
            .disposed(by: disposeBag)
    }

    private func loadMockData() {
        // 创建模拟商品
        let product1 = Product(
            id: 1,
            name: "优质狗粮 成犬专用 2.5kg",
            categoryId: 1,
            brand: "皇家",
            price: 89.00,
            originalPrice: 129.00,
            stock: 100,
            sales: 256,
            mainImage: "https://picsum.photos/200/200?random=1",
            album: nil,
            description: "营养均衡的成犬专用狗粮",
            detail: nil,
            status: 1,
            createTime: nil,
            updateTime: nil
        )

        let product2 = Product(
            id: 2,
            name: "猫咪玩具球 互动玩具",
            categoryId: 2,
            brand: "宠爱",
            price: 25.00,
            originalPrice: nil,
            stock: 50,
            sales: 89,
            mainImage: "https://picsum.photos/200/200?random=2",
            album: nil,
            description: "猫咪最爱的互动玩具",
            detail: nil,
            status: 1,
            createTime: nil,
            updateTime: nil
        )

        let product3 = Product(
            id: 3,
            name: "宠物洗护用品套装",
            categoryId: 3,
            brand: "洁净",
            price: 68.00,
            originalPrice: 88.00,
            stock: 30,
            sales: 145,
            mainImage: "https://picsum.photos/200/200?random=3",
            album: nil,
            description: "专业宠物洗护套装",
            detail: nil,
            status: 1,
            createTime: nil,
            updateTime: nil
        )

        let product4 = Product(
            id: 4,
            name: "宠物营养膏 增强免疫力",
            categoryId: 4,
            brand: "健康",
            price: 45.00,
            originalPrice: nil,
            stock: 80,
            sales: 67,
            mainImage: "https://picsum.photos/200/200?random=4",
            album: nil,
            description: "增强宠物免疫力的营养膏",
            detail: nil,
            status: 1,
            createTime: nil,
            updateTime: nil
        )

        // 创建购物车项目
        var mockItems = [
            CartItem(
                id: 1,
                userId: 1,
                productId: 1,
                quantity: 2,
                createTime: nil,
                updateTime: nil
            ),
            CartItem(
                id: 2,
                userId: 1,
                productId: 2,
                quantity: 1,
                createTime: nil,
                updateTime: nil
            ),
            CartItem(
                id: 3,
                userId: 1,
                productId: 3,
                quantity: 1,
                createTime: nil,
                updateTime: nil
            ),
            CartItem(
                id: 4,
                userId: 1,
                productId: 4,
                quantity: 3,
                createTime: nil,
                updateTime: nil
            )
        ]

        // 关联商品信息并设置UI状态
        mockItems[0].product = product1
        mockItems[0].isSelected = true
        mockItems[0].maxQuantity = 10

        mockItems[1].product = product2
        mockItems[1].isSelected = true
        mockItems[1].maxQuantity = 5

        mockItems[2].product = product3
        mockItems[2].isSelected = false
        mockItems[2].maxQuantity = 3

        mockItems[3].product = product4
        mockItems[3].isSelected = true
        mockItems[3].maxQuantity = 8

        cartItems.accept(mockItems)
    }
}
