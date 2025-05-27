//
//  ProductDetailViewController.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

class ProductDetailViewController: UIViewController {

    // MARK: - 属性

    private let disposeBag = DisposeBag()
    private let productId: Int64
    private var product: Product?

    // MARK: - UI组件

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = AppTheme.Color.background
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.background
        return view
    }()

    private lazy var productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppTheme.Color.cardBackground
        imageView.layer.cornerRadius = 12
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.title2()
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var brandLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textSecondary
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.title3()
        label.textColor = AppTheme.Color.primary
        return label
    }()

    private lazy var originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textSecondary
        return label
    }()

    private lazy var stockLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textSecondary
        return label
    }()

    private lazy var salesLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.footnote()
        label.textColor = AppTheme.Color.textSecondary
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.body()
        label.textColor = AppTheme.Color.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("加入购物车", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTheme.Font.button()
        button.backgroundColor = AppTheme.Color.primary
        button.layer.cornerRadius = 25
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - 初始化

    init(productId: Int64) {
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadProductDetail()
    }

    // MARK: - UI设置

    private func setupUI() {
        title = "商品详情"
        view.backgroundColor = AppTheme.Color.background

        // 添加子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(productImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(brandLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(originalPriceLabel)
        contentView.addSubview(stockLabel)
        contentView.addSubview(salesLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addToCartButton)

        view.addSubview(loadingIndicator)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        productImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
        }

        originalPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(12)
        }

        stockLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
        }

        salesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(stockLabel)
            make.left.equalTo(stockLabel.snp.right).offset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(stockLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }

        addToCartButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-30)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - 数据绑定

    private func setupBindings() {
        addToCartButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addToCart()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 数据加载

    private func loadProductDetail() {
        loadingIndicator.startAnimating()

        NetworkManager.shared.request(PetAPI.getProductDetail(id: Int(productId)))
            .subscribe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (product: Product) in
                    self?.loadingIndicator.stopAnimating()
                    self?.product = product
                    self?.updateUI(with: product)
                },
                onError: { [weak self] error in
                    self?.loadingIndicator.stopAnimating()
                    Utilities.showError(in: self?.view ?? UIView(), message: "获取商品详情失败: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }

    private func updateUI(with product: Product) {
        nameLabel.text = product.name
        brandLabel.text = product.brand ?? "暂无品牌信息"
        priceLabel.text = String(format: "¥%.2f", product.price)

        if let originalPrice = product.originalPrice, originalPrice > product.price {
            originalPriceLabel.text = String(format: "¥%.2f", originalPrice)
            originalPriceLabel.attributedText = NSAttributedString(
                string: originalPriceLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
        }

        stockLabel.text = "库存: \(product.stock ?? 0)"
        salesLabel.text = "销量: \(product.sales ?? 0)"
        descriptionLabel.text = product.description ?? "暂无商品描述"

        // 加载商品图片
        if let imageUrl = product.mainImage, let url = URL(string: imageUrl) {
            productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }

    private func addToCart() {
        guard let product = product else { return }

        // 显示加载指示器
        let hud = Utilities.showLoading(in: view)

        CartService.shared.addToCart(productId: product.id, quantity: 1)
            .subscribe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] _ in
                    Utilities.hideLoading(hud)
                    Utilities.showSuccess(in: self?.view ?? UIView(), message: "已添加到购物车")
                },
                onError: { [weak self] error in
                    Utilities.hideLoading(hud)
                    Utilities.showError(in: self?.view ?? UIView(), message: "添加失败: \(error.localizedDescription)")
                }
            )
            .disposed(by: disposeBag)
    }
}
