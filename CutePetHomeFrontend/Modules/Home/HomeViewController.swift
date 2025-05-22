//
//  HomeViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import FSPagerView
import Kingfisher

class HomeViewController: UIViewController {

    // MARK: - UI组件

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

    // 轮播图视图
    private lazy var bannerView: FSPagerView = {
        let pagerView = FSPagerView()
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "bannerCell")
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = true
        pagerView.interitemSpacing = 0
        pagerView.backgroundColor = .white
        pagerView.layer.cornerRadius = AppTheme.Metrics.cornerRadiusMedium
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

    // 功能区容器
    private lazy var functionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppTheme.Metrics.cornerRadiusMedium
        view.clipsToBounds = true
        return view
    }()

    // 养宠知识容器
    private lazy var knowledgeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppTheme.Metrics.cornerRadiusMedium
        view.clipsToBounds = true
        return view
    }()

    // 养宠知识标题
    private lazy var knowledgeTitle: UILabel = {
        let label = UILabel()
        label.text = "养宠知识"
        label.font = AppTheme.Font.title3()
        label.textColor = AppTheme.Color.textPrimary
        return label
    }()

    // 养宠知识更多按钮
    private lazy var knowledgeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("更多", for: .normal)
        button.setTitleColor(AppTheme.Color.textTertiary, for: .normal)
        button.titleLabel?.font = AppTheme.Font.footnote()
        return button
    }()

    // 养宠知识列表
    private lazy var knowledgeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(KnowledgeCell.self, forCellReuseIdentifier: "KnowledgeCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .white
        return tableView
    }()



    // MARK: - 属性

    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // 添加调试信息
        print("HomeViewController viewDidLoad")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 确保轮播图在视图出现时刷新
        if viewModel.bannerItems.value.isEmpty {
            print("轮播图数据为空，重新获取数据")
            viewModel.fetchBanners()
        } else {
            print("轮播图数据已存在: \(viewModel.bannerItems.value.count) 条")
            bannerView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 在视图布局完成后重新设置功能按钮，确保布局正确
        if !viewModel.functionItems.value.isEmpty {
            setupFunctionButtons(viewModel.functionItems.value)
        }
    }

    // MARK: - UI设置

    private func setupUI() {
        // 设置导航栏
        title = "萌宠之家"
        view.backgroundColor = AppTheme.Color.background

        // 添加滚动视图
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 添加内容容器
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(view)
        }

        // 设置轮播图
        setupBannerView()

        // 设置功能区
        setupFunctionArea()

        // 设置养宠知识区域
        setupKnowledgeArea()

        // 更新内容容器底部约束
        knowledgeContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }
    }

    private func setupBannerView() {
        contentView.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
            make.height.equalTo(180)
        }

        contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(bannerView).offset(-AppTheme.Metrics.spacingSmall)
            make.centerX.equalTo(bannerView)
            make.height.equalTo(20)
        }
    }

    private func setupFunctionArea() {
        // 添加功能区容器
        contentView.addSubview(functionContainer)
        functionContainer.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom).offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
            make.height.equalTo(100)
        }
    }

    private func setupKnowledgeArea() {
        // 添加养宠知识容器
        contentView.addSubview(knowledgeContainer)
        knowledgeContainer.snp.makeConstraints { make in
            make.top.equalTo(functionContainer.snp.bottom).offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }

        // 添加标题和更多按钮
        knowledgeContainer.addSubview(knowledgeTitle)
        knowledgeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.left.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
        }

        knowledgeContainer.addSubview(knowledgeMoreButton)
        knowledgeMoreButton.snp.makeConstraints { make in
            make.centerY.equalTo(knowledgeTitle)
            make.right.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
        }

        // 添加列表
        knowledgeContainer.addSubview(knowledgeTableView)
        knowledgeTableView.snp.makeConstraints { make in
            make.top.equalTo(knowledgeTitle.snp.bottom).offset(AppTheme.Metrics.spacingMedium)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-AppTheme.Metrics.spacingMedium)
            make.height.equalTo(300) // 固定高度，根据内容调整
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

        // 绑定轮播图数据
        viewModel.bannerItems
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.pageControl.numberOfPages = items.count
                self.bannerView.reloadData()
            })
            .disposed(by: disposeBag)

        // 绑定功能区数据
        viewModel.functionItems
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.setupFunctionButtons(items)
            })
            .disposed(by: disposeBag)

        // 绑定养宠知识数据
        viewModel.petKnowledgeItems
            .bind(to: knowledgeTableView.rx.items(cellIdentifier: "KnowledgeCell", cellType: KnowledgeCell.self)) { index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }

    // 设置功能按钮
    private func setupFunctionButtons(_ items: [FunctionItem]) {
        // 清除现有的按钮
        for subview in functionContainer.subviews {
            subview.removeFromSuperview()
        }

        // 获取屏幕宽度，确保即使在首次加载时也能正确计算
        let screenWidth = UIScreen.main.bounds.width
        let containerWidth = screenWidth - (AppTheme.Metrics.spacingMedium * 2)

        // 计算按钮宽度，使用屏幕宽度而不是容器宽度
        let buttonWidth = (containerWidth - AppTheme.Metrics.spacingMedium * 2) / CGFloat(items.count)

        // 添加新按钮，使用等分布局
        for (index, item) in items.enumerated() {
            let button = createFunctionButton(item: item)
            functionContainer.addSubview(button)

            // 使用更可靠的布局方式
            if items.count == 4 {
                // 四个按钮时使用等分布局
                button.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(containerWidth / 4)
                    if index == 0 {
                        make.left.equalToSuperview()
                    } else if index == items.count - 1 {
                        make.right.equalToSuperview()
                    } else {
                        make.left.equalToSuperview().offset(containerWidth / 4 * CGFloat(index))
                    }
                }
            } else {
                // 其他数量的按钮使用原来的布局方式，但使用更可靠的宽度计算
                button.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(buttonWidth)
                    make.left.equalToSuperview().offset(buttonWidth * CGFloat(index))
                }
            }
        }

        // 强制布局更新，确保视图立即更新
        functionContainer.layoutIfNeeded()
    }

    // 创建功能按钮
    private func createFunctionButton(item: FunctionItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear // 确保背景透明

        // 创建图标按钮
        let iconButton = UIButton()
        iconButton.setImage(UIImage(systemName: item.icon), for: .normal)
        iconButton.tintColor = .white
        iconButton.backgroundColor = UIColor(hex: item.color)
        iconButton.layer.cornerRadius = 25
        iconButton.clipsToBounds = true // 确保圆角效果

        // 添加点击事件
        iconButton.tag = Int(item.id) ?? 0
        iconButton.addTarget(self, action: #selector(functionButtonTapped(_:)), for: .touchUpInside)

        // 创建标题标签
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textAlignment = .center
        titleLabel.font = AppTheme.Font.footnote()
        titleLabel.textColor = AppTheme.Color.textPrimary
        titleLabel.numberOfLines = 1 // 确保单行显示
        titleLabel.adjustsFontSizeToFitWidth = true // 自动调整字体大小以适应宽度
        titleLabel.minimumScaleFactor = 0.8 // 最小缩放比例

        // 添加到容器
        containerView.addSubview(iconButton)
        containerView.addSubview(titleLabel)

        // 设置约束
        iconButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppTheme.Metrics.spacingMedium)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconButton.snp.bottom).offset(AppTheme.Metrics.spacingSmall)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(2) // 添加小边距
            make.bottom.lessThanOrEqualToSuperview().offset(-2) // 确保底部有足够空间
        }

        return containerView
    }

    // 功能按钮点击事件
    @objc private func functionButtonTapped(_ sender: UIButton) {
        let buttonId = sender.tag
        print("点击了功能按钮: ID=\(buttonId)")

        // 根据按钮ID执行相应操作
        switch buttonId {
        case 1: // 宠物商城
            // 跳转到商城页面
            tabBarController?.selectedIndex = 1
        case 2: // 健康服务
            // 显示健康服务功能尚未开放提示
            Utilities.showInfo(in: view, message: "健康服务功能即将上线，敬请期待")
        case 3: // 美容洗护
            // 显示美容洗护功能尚未开放提示
            Utilities.showInfo(in: view, message: "美容洗护功能即将上线，敬请期待")
        case 4: // 宠友社区
            // 显示宠友社区功能尚未开放提示
            Utilities.showInfo(in: view, message: "宠友社区功能即将上线，敬请期待")
        default:
            break
        }
    }
}

// MARK: - FSPagerViewDataSource, FSPagerViewDelegate

extension HomeViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewModel.bannerItems.value.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "bannerCell", at: index)
        let item = viewModel.bannerItems.value[index]

        // 设置图片（从Kingfisher缓存加载）
        cell.imageView?.contentMode = .scaleAspectFill

        // 处理图片URL
        var imageURL: URL?
        if item.imageUrl.hasPrefix("http") {
            // 如果是完整的URL（从后端获取的）
            imageURL = URL(string: item.imageUrl)
        } else {
            // 如果是本地图片名称（备份数据）
            imageURL = Bundle.main.url(forResource: item.imageUrl, withExtension: "jpg")
        }

        // 确保图片视图存在
        if cell.imageView == nil {
            print("警告: 轮播图单元格的imageView为nil")
        }

        // 使用Kingfisher加载图片，添加成功和失败回调
        cell.imageView?.kf.setImage(
            with: imageURL,
            placeholder: UIImage(systemName: "photo"),
            options: [.transition(.fade(0.2))]
//            completionHandler: { result in
//                switch result {
//                case .success(let value):
//                    print("轮播图图片加载成功: \(value.source.url?.absoluteString ?? "未知URL")")
//                case .failure(let error):
//                    print("轮播图图片加载失败: \(error.localizedDescription)")
//                }
//            }
        )

        // 设置标题
        if cell.textLabel == nil {
            let label = UILabel()
            label.textColor = .white
            label.font = AppTheme.Font.body(weight: .medium)
            label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            label.textAlignment = .center
            label.tag = 100
            cell.addSubview(label)

            label.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(40)
            }
        }

        let label = cell.viewWithTag(100) as? UILabel
        label?.text = item.title

        return cell
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let banner = viewModel.bannerItems.value[index]
        print("点击了轮播图: \(banner.title), linkUrl: \(banner.linkUrl)")

        // 如果有链接URL，可以在这里处理跳转
        if !banner.linkUrl.isEmpty {
            // 这里可以添加跳转逻辑
            print("准备跳转到: \(banner.linkUrl)")
        }

        // 取消选中状态
        pagerView.deselectItem(at: index, animated: true)
    }
}


