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
import FSPagerView
import MJRefresh

class MallViewController: UIViewController {

    // MARK: - UI组件

    // 搜索栏
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索商品"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = AppTheme.Color.primary
        return searchBar
    }()

    // 滚动视图（主容器）
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = AppTheme.Color.background
        scrollView.refreshControl = refreshControl
        return scrollView
    }()

    // 内容容器
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        return view
    }()

    // 刷新控件
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.Color.primary
        return refreshControl
    }()

    // 轮播图容器
    private lazy var bannerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppTheme.Metrics.cornerRadiusMedium
        view.clipsToBounds = true
        return view
    }()

    // 轮播图视图
    private lazy var bannerView: FSPagerView = {
        let pagerView = FSPagerView()
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "bannerCell")
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = true
        pagerView.interitemSpacing = 0
        pagerView.backgroundColor = .white
        pagerView.layer.cornerRadius = AppTheme.Metrics.cornerRadiusSmall
        pagerView.clipsToBounds = true
        // 设置代理和数据源
        pagerView.dataSource = self
        pagerView.delegate = self
        return pagerView
    }()

    // 轮播图页面控制器
    private lazy var pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.contentHorizontalAlignment = .center
        pageControl.setFillColor(AppTheme.Color.primary, for: .selected)
        pageControl.setFillColor(UIColor.lightGray.withAlphaComponent(0.3), for: .normal)
        pageControl.itemSpacing = 8
        pageControl.interitemSpacing = 8
        return pageControl
    }()

    // 分类标题
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "商品分类"
        label.font = AppTheme.Font.title3()
        label.textColor = AppTheme.Color.textPrimary
        return label
    }()

    // 分类集合视图
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        collectionView.delegate = self
        return collectionView
    }()

    // 商品标题
    private lazy var productTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "商品列表"
        label.font = AppTheme.Font.title3()
        label.textColor = AppTheme.Color.textPrimary
        return label
    }()

    // 商品集合视图
    private lazy var productCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = AppTheme.Color.background
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        collectionView.isScrollEnabled = false // 禁用滚动，使用外部scrollView
        return collectionView
    }()

    // 加载更多页脚
    private lazy var loadMoreFooter: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            self?.viewModel.loadMoreProducts()
        }
        footer.setTitle("上拉加载更多", for: .idle)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("没有更多数据了", for: .noMoreData)
        return footer
    }()

    // MARK: - 属性

    private let viewModel = MallViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // 加载初始数据
        viewModel.loadInitialData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 更新商品集合视图高度
        updateProductCollectionViewHeight()
    }

    // MARK: - UI设置

    private func setupUI() {
        // 设置导航栏
        title = "宠物商城"
        view.backgroundColor = AppTheme.Color.background

        // 添加搜索栏
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }

        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        // 添加内容容器
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 设置轮播图
        setupBannerView()

        // 设置分类区域
        setupCategoryArea()

        // 设置商品区域
        setupProductArea()

        // 设置加载更多
        productCollectionView.mj_footer = loadMoreFooter
    }

    private func setupBannerView() {
        contentView.addSubview(bannerContainer)
        bannerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
            make.height.equalTo(180)
        }

        bannerContainer.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bannerContainer.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-AppTheme.Metrics.spacingSmall)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
    }

    private func setupCategoryArea() {
        // 添加分类标题
        contentView.addSubview(categoryTitleLabel)
        categoryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bannerContainer.snp.bottom).offset(AppTheme.Metrics.spacingLarge)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
        }

        // 添加分类集合视图
        contentView.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.bottom).offset(AppTheme.Metrics.spacingMedium)
            make.left.right.equalToSuperview()
            make.height.equalTo(100) // 增加高度以适应内容
        }
    }

    private func setupProductArea() {
        // 添加商品标题
        contentView.addSubview(productTitleLabel)
        productTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(AppTheme.Metrics.spacingLarge)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
        }

        // 添加商品集合视图
        contentView.addSubview(productCollectionView)
        productCollectionView.snp.makeConstraints { make in
            make.top.equalTo(productTitleLabel.snp.bottom).offset(AppTheme.Metrics.spacingMedium)
            make.left.right.equalToSuperview()
            make.height.equalTo(500) // 初始高度，后续会动态调整
            make.bottom.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        // 绑定刷新控件
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshData()
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)

        // 绑定搜索栏
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] query in
                self?.viewModel.setSearchKeyword(query.isEmpty ? nil : query)
            })
            .disposed(by: disposeBag)

        // 绑定轮播图数据
        viewModel.hotProducts
            .subscribe(onNext: { [weak self] products in
                guard let self = self else { return }
                self.pageControl.numberOfPages = products.count
                self.bannerView.reloadData()
            })
            .disposed(by: disposeBag)

        // 绑定分类数据
        viewModel.categories
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCell.reuseIdentifier, cellType: CategoryCell.self)) { index, category, cell in
                cell.configure(with: category)
            }
            .disposed(by: disposeBag)

        // 监听分类数据加载完成，默认选中第一个分类
        viewModel.categories
            .skip(1) // 跳过初始空数组
            .take(1) // 只取第一次有数据的事件
            .subscribe(onNext: { [weak self] categories in
                guard let self = self, !categories.isEmpty else { return }

                // 默认选中第一个分类
                let indexPath = IndexPath(item: 0, section: 0)
                self.categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)

                // 通知ViewModel选中了第一个分类
                if let firstCategory = categories.first {
                    self.viewModel.selectCategory(firstCategory.id)
                }
            })
            .disposed(by: disposeBag)

        // 绑定商品数据
        viewModel.products
            .bind(to: productCollectionView.rx.items(cellIdentifier: ProductCell.reuseIdentifier, cellType: ProductCell.self)) { index, product, cell in
                cell.configure(with: product)
            }
            .disposed(by: disposeBag)

        // 绑定分类选择
        categoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, let categories = self.viewModel.categories.value as? [ProductCategory], indexPath.item < categories.count else { return }
                let category = categories[indexPath.item]
                self.viewModel.selectCategory(category.id)
            })
            .disposed(by: disposeBag)

        // 绑定商品选择
        productCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self, let products = self.viewModel.products.value as? [Product], indexPath.item < products.count else { return }
                let product = products[indexPath.item]
                self.showProductDetail(product)
            })
            .disposed(by: disposeBag)

        // 绑定加载状态
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.productCollectionView.mj_footer?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        // 绑定是否有更多数据
        viewModel.hasMoreData
            .subscribe(onNext: { [weak self] hasMore in
                if !hasMore {
                    self?.productCollectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
            })
            .disposed(by: disposeBag)

        // 绑定错误消息
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                Utilities.showError(in: self?.view ?? UIView(), message: message)
            })
            .disposed(by: disposeBag)

        // 监听商品数据变化，更新集合视图高度
        viewModel.products
            .subscribe(onNext: { [weak self] _ in
                self?.updateProductCollectionViewHeight()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 辅助方法

    private func updateProductCollectionViewHeight() {
        // 计算商品集合视图的内容高度
        let productsCount = viewModel.products.value.count
        if productsCount == 0 {
            // 如果没有商品，设置一个最小高度
            productCollectionView.snp.updateConstraints { make in
                make.height.equalTo(200)
            }
            return
        }

        // 计算行数（每行2个商品）
        let rows = ceil(Double(productsCount) / 2.0)

        // 计算每个单元格的高度（宽度的1.5倍）
        let cellWidth = (view.bounds.width - 40) / 2 // 考虑左右边距和中间间距
        let cellHeight = cellWidth * 1.5

        // 计算总高度（包括行间距和上下边距）
        let totalHeight = rows * cellHeight + (rows - 1) * 15 + 20 // 15是行间距，20是上下边距

        // 更新约束
        productCollectionView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }

        // 强制布局更新
        view.layoutIfNeeded()
    }

    private func showProductDetail(_ product: Product) {
        // 这里可以跳转到商品详情页
        print("查看商品详情: \(product.name)")

        // 显示提示信息
        Utilities.showInfo(in: view, message: "商品详情功能即将上线，敬请期待")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MallViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            // 分类单元格大小
            return CGSize(width: 70, height: 90) // 调整宽度和高度
        } else {
            // 商品单元格大小
            let width = (collectionView.bounds.width - 40) / 2 // 考虑左右边距和中间间距
            return CGSize(width: width, height: width * 1.5)
        }
    }
}

// MARK: - FSPagerViewDataSource, FSPagerViewDelegate

extension MallViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.hotProducts.value.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "bannerCell", at: index)
        let product = viewModel.hotProducts.value[index]

        // 设置图片
        cell.imageView?.contentMode = .scaleAspectFill

        // 处理图片URL
        if let imageUrl = product.mainImage, !imageUrl.isEmpty {
            let url = URL(string: imageUrl)
            cell.imageView?.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            // 使用占位图
            cell.imageView?.image = UIImage(systemName: "photo")
        }

        // 设置标题
        cell.textLabel?.text = product.name
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = AppTheme.Font.body()
        cell.textLabel?.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let product = viewModel.hotProducts.value[index]
        showProductDetail(product)

        // 取消选中状态
        pagerView.deselectItem(at: index, animated: true)
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}
