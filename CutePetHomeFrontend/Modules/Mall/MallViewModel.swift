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
        fetchProducts()
    }

    /// 刷新数据
    func refreshData() {
        resetProductList()
        fetchCategories()
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
        resetProductList()
        fetchProducts()
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

                    // 在分类列表前添加"全部"分类
                    let allCategory = ProductCategory(id: 0, name: "全部", sort: 0, icon: "square.grid.2x2", status: 1)
                    let allCategories = [allCategory] + categories
                    self?.categories.accept(allCategories)

                    // 默认选择"全部"分类（categoryId为nil）
                    self?.selectedCategoryId.accept(nil)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept("获取分类失败: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }

    /// 获取商品列表
    private func fetchProducts(isLoadMore: Bool = false) {
        isLoading.accept(true)

        let productsRequest: Observable<(data: [Product], pagination: Pagination?)> = NetworkManager.shared.requestWithPagination(PetAPI.getProducts(
            categoryId: selectedCategoryId.value,
            keyword: searchKeyword.value?.isEmpty == false ? searchKeyword.value : nil,
            page: currentPage,
            size: pageSize
        ))

        productsRequest
            .subscribe(
                onNext: { [weak self] result in
                    guard let self = self else { return }
                    self.isLoading.accept(false)

                    let products = result.data
                    let pagination = result.pagination

                    // 判断是否还有更多数据
                    if let pagination = pagination {
                        self.hasMoreData.accept(pagination.currentPage < pagination.totalPage)
                    } else {
                        self.hasMoreData.accept(products.count >= self.pageSize)
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
                }
            )
            .disposed(by: disposeBag)
    }
}
