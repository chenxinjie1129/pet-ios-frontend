//
//  MallViewModel.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation
import RxSwift
import RxCocoa

class MallViewModel {

    // MARK: - 属性

    // 分类数据
    let categories = BehaviorRelay<[ProductCategory]>(value: [])

    // 商品数据
    let products = BehaviorRelay<[Product]>(value: [])

    // 热门商品数据（用于轮播图）
    let hotProducts = BehaviorRelay<[Product]>(value: [])

    // 当前选中的分类ID
    let selectedCategoryId = BehaviorRelay<Int?>(value: nil)

    // 搜索关键词
    let searchKeyword = BehaviorRelay<String?>(value: nil)

    // 分页信息
    private var currentPage = 1
    private let pageSize = 10

    // 是否有更多数据
    let hasMoreData = BehaviorRelay<Bool>(value: true)

    // 是否正在加载
    let isLoading = BehaviorRelay<Bool>(value: false)

    // 错误信息
    let errorMessage = PublishRelay<String>()

    // DisposeBag
    private let disposeBag = DisposeBag()

    // MARK: - 初始化

    init() {
        // 监听分类选择变化
        selectedCategoryId
            .skip(1) // 跳过初始值
            .subscribe(onNext: { [weak self] _ in
                self?.resetProductList()
                self?.fetchProducts()
            })
            .disposed(by: disposeBag)

        // 监听搜索关键词变化
        searchKeyword
            .skip(1) // 跳过初始值
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // 防抖
            .subscribe(onNext: { [weak self] _ in
                self?.resetProductList()
                self?.fetchProducts()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 公共方法

    /// 加载初始数据
    func loadInitialData() {
        fetchCategories()
        fetchHotProducts()
        fetchProducts()
    }

    /// 刷新数据
    func refreshData() {
        resetProductList()
        fetchCategories()
        fetchHotProducts()
        fetchProducts()
    }

    /// 加载更多商品
    func loadMoreProducts() {
        guard !isLoading.value && hasMoreData.value else { return }
        currentPage += 1
        fetchProducts(isLoadMore: true)
    }

    /// 选择分类
    func selectCategory(_ categoryId: Int?) {
        selectedCategoryId.accept(categoryId)
    }

    /// 设置搜索关键词
    func setSearchKeyword(_ keyword: String?) {
        searchKeyword.accept(keyword)
    }

    // MARK: - 私有方法

    /// 重置商品列表
    private func resetProductList() {
        currentPage = 1
        hasMoreData.accept(true)
        products.accept([])
    }

    /// 获取商品分类
    private func fetchCategories() {
        isLoading.accept(true)

        NetworkManager.shared.request(PetAPI.getProductCategories)
            .subscribe(
                onNext: { [weak self] (categories: [ProductCategory]) in
                    self?.isLoading.accept(false)
                    self?.categories.accept(categories)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept("获取分类失败: \(error.localizedDescription)")
                    // 使用模拟数据
                    self?.loadMockCategories()
                }
            )
            .disposed(by: disposeBag)
    }

    /// 获取热门商品
    private func fetchHotProducts() {
        isLoading.accept(true)

        // 获取热门商品（销量最高的几个）
        NetworkManager.shared.request(PetAPI.getProducts(categoryId: nil, keyword: nil, page: 1, size: 5))
            .subscribe(
                onNext: { [weak self] (products: [Product]) in
                    self?.isLoading.accept(false)
                    self?.hotProducts.accept(products)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept("获取热门商品失败: \(error.localizedDescription)")
                    // 使用模拟数据
                    self?.loadMockHotProducts()
                }
            )
            .disposed(by: disposeBag)
    }

    /// 获取商品列表
    private func fetchProducts(isLoadMore: Bool = false) {
        isLoading.accept(true)

        NetworkManager.shared.request(PetAPI.getProducts(
            categoryId: selectedCategoryId.value,
            keyword: searchKeyword.value,
            page: currentPage,
            size: pageSize
        ))
        .subscribe(
            onNext: { [weak self] (products: [Product]) in
                guard let self = self else { return }
                self.isLoading.accept(false)

                // 判断是否还有更多数据
                if products.count < self.pageSize {
                    self.hasMoreData.accept(false)
                }

                // 更新商品列表
                if isLoadMore {
                    let currentProducts = self.products.value
                    self.products.accept(currentProducts + products)
                } else {
                    self.products.accept(products)
                }
            },
            onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.errorMessage.accept("获取商品失败: \(error.localizedDescription)")

                // 使用模拟数据
                if !isLoadMore {
                    self?.loadMockProducts()
                }
            }
        )
        .disposed(by: disposeBag)
    }

    // MARK: - 模拟数据

    /// 加载模拟分类数据
    private func loadMockCategories() {
        let mockCategories = [
            ProductCategory(id: 1, name: "猫咪用品", parentId: 0, level: 1, sort: 1, icon: "cat.fill", status: 1),
            ProductCategory(id: 2, name: "狗狗用品", parentId: 0, level: 1, sort: 2, icon: "hare.fill", status: 1),
            ProductCategory(id: 3, name: "小宠用品", parentId: 0, level: 1, sort: 3, icon: "tortoise.fill", status: 1),
            ProductCategory(id: 4, name: "猫粮", parentId: 1, level: 2, sort: 1, icon: "fork.knife", status: 1),
            ProductCategory(id: 5, name: "猫砂", parentId: 1, level: 2, sort: 2, icon: "square.grid.3x3.fill", status: 1),
            ProductCategory(id: 6, name: "猫玩具", parentId: 1, level: 2, sort: 3, icon: "gamecontroller.fill", status: 1),
            ProductCategory(id: 7, name: "狗粮", parentId: 2, level: 2, sort: 1, icon: "fork.knife", status: 1),
            ProductCategory(id: 8, name: "狗窝", parentId: 2, level: 2, sort: 2, icon: "house.fill", status: 1),
            ProductCategory(id: 9, name: "狗玩具", parentId: 2, level: 2, sort: 3, icon: "gamecontroller.fill", status: 1)
        ]

        categories.accept(mockCategories)
    }

    /// 加载模拟热门商品数据
    private func loadMockHotProducts() {
        let mockHotProducts = createMockProducts(count: 5)
        hotProducts.accept(mockHotProducts)
    }

    /// 加载模拟商品数据
    private func loadMockProducts() {
        let mockProducts = createMockProducts(count: 10)
        products.accept(mockProducts)
    }

    /// 创建模拟商品数据
    private func createMockProducts(count: Int) -> [Product] {
        var mockProducts: [Product] = []

        for i in 1...count {
            let categoryId = (i % 3) + 1 // 1, 2, 3
            let price = Double(Int.random(in: 1000...10000)) / 100 // 10.00 - 100.00
            let originalPrice = Double(Int.random(in: Int(price * 100)...Int(price * 150))) / 100 // 原价比现价高

            let product = Product(
                id: i,
                name: "模拟商品 \(i)",
                categoryId: categoryId,
                brand: "品牌\(i % 5 + 1)",
                price: price,
                originalPrice: originalPrice,
                stock: Int.random(in: 10...100),
                sales: Int.random(in: 0...50),
                mainImage: nil,
                album: nil,
                description: "这是一个模拟商品的描述",
                detail: "这是一个模拟商品的详细信息",
                status: 1,
                createTime: nil,
                updateTime: nil
            )

            mockProducts.append(product)
        }

        return mockProducts
    }
}
