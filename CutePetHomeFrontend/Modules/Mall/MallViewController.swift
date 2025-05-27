//
//  MallViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MJRefresh
import Kingfisher

class MallViewController: UIViewController {

    // MARK: - UI组件

    // 顶部搜索容器
    private lazy var searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()

    // 搜索框
    private lazy var searchBar: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.Color.border.cgColor
        return view
    }()

    // 搜索图标
    private lazy var searchIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = AppTheme.Color.textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // 搜索文本框
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "搜索宠物用品、食品..."
        textField.font = AppTheme.Font.body(size: 15)
        textField.textColor = AppTheme.Color.textPrimary
        textField.borderStyle = .none
        return textField
    }()

    // 购物车按钮
    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "cart"), for: .normal)
        button.tintColor = AppTheme.Color.textPrimary
        button.backgroundColor = AppTheme.Color.background
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.Color.border.cgColor
        return button
    }()

    // 主内容容器
    private lazy var mainContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        return view
    }()

    // 左侧分类容器
    private lazy var categoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    // 分类表格视图
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CategoryTableCell.self, forCellReuseIdentifier: CategoryTableCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // 右侧商品容器
    private lazy var productContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        return view
    }()

    // 商品集合视图
    private lazy var productCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.register(ProductGridCell.self, forCellWithReuseIdentifier: ProductGridCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    // 加载更多页脚
    private lazy var loadMoreFooter: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            self?.loadMoreProducts()
        }
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("没有更多数据了", for: .noMoreData)
        return footer
    }()

    // 下拉刷新
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.Color.primary
        return refreshControl
    }()

    // MARK: - 属性

    private let disposeBag = DisposeBag()
    private let viewModel = MallViewModel()

    // 分类数据
    private var categories: [CategoryModel] = []
    private var selectedCategoryIndex: Int = 0

    // 商品数据
    private var products: [ProductModel] = []

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadInitialData()
    }

    // MARK: - UI设置

    private func setupUI() {
        title = "宠物商城"
        view.backgroundColor = AppTheme.Color.background
        navigationController?.navigationBar.prefersLargeTitles = false

        setupSearchArea()
        setupMainContent()

        productCollectionView.mj_footer = loadMoreFooter
        productCollectionView.refreshControl = refreshControl
    }

    private func setupSearchArea() {
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchBar)
        searchContainer.addSubview(cartButton)

        searchBar.addSubview(searchIcon)
        searchBar.addSubview(searchTextField)

        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(cartButton.snp.left).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        cartButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    private func setupMainContent() {
        view.addSubview(mainContainer)
        mainContainer.addSubview(categoryContainer)
        mainContainer.addSubview(productContainer)

        categoryContainer.addSubview(categoryTableView)
        productContainer.addSubview(productCollectionView)

        mainContainer.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        categoryContainer.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(100)
        }

        productContainer.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(categoryContainer.snp.right)
        }

        categoryTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        productCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 绑定ViewModel数据
        viewModel.categories
            .subscribe(onNext: { [weak self] categories in
                self?.categories = categories.map { CategoryModel(from: $0) }
                self?.categoryTableView.reloadData()

                // 默认选择第一个分类
                if !categories.isEmpty {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    self?.selectedCategoryIndex = 0
                }
            })
            .disposed(by: disposeBag)

        viewModel.products
            .subscribe(onNext: { [weak self] products in
                self?.products = products.map { ProductModel(from: $0) }
                self?.productCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                    self?.loadMoreFooter.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                Utilities.showError(in: self?.view ?? UIView(), message: message)
            })
            .disposed(by: disposeBag)

        // 搜索文本框绑定
        searchTextField.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchKeyword)
            .disposed(by: disposeBag)

        // 购物车按钮绑定
        cartButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showCart()
            })
            .disposed(by: disposeBag)

        // 下拉刷新绑定
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
            })
            .disposed(by: disposeBag)

        // 上拉加载更多绑定
        loadMoreFooter.setRefreshingTarget(self, refreshingAction: #selector(loadMoreProducts))
    }

    // MARK: - 事件处理

    private func showCart() {
        // 跳转到购物车Tab
        tabBarController?.selectedIndex = 2
    }



    @objc private func loadMoreProducts() {
        viewModel.loadMoreProducts()
    }

    private func showProductDetail(_ product: ProductModel) {
        let detailVC = ProductDetailViewController(productId: Int64(product.id))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MallViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableCell.reuseIdentifier, for: indexPath) as! CategoryTableCell
        let category = categories[indexPath.row]
        cell.configure(with: category, isSelected: indexPath.row == selectedCategoryIndex)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MallViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.row

        // 获取选中的分类ID
        let selectedCategory = categories[indexPath.row]
        let categoryId = selectedCategory.id == 0 ? nil : selectedCategory.id // 0表示全部分类

        // 通知ViewModel更新分类
        viewModel.selectCategory(categoryId)

        tableView.reloadData() // 刷新选中状态
    }
}

// MARK: - UICollectionViewDataSource

extension MallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductGridCell.reuseIdentifier, for: indexPath) as! ProductGridCell
        let product = products[indexPath.item]
        cell.configure(with: product)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MallViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        showProductDetail(product)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MallViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算商品单元格大小 - 右侧区域2列布局
        let containerWidth = collectionView.bounds.width
        let spacing: CGFloat = 8
        let sectionInsets: CGFloat = 16 // 左右各8
        let itemWidth = (containerWidth - sectionInsets - spacing) / 2
        let itemHeight = itemWidth * 1.3 // 高宽比1.3:1

        return CGSize(width: itemWidth, height: itemHeight)
    }
}
