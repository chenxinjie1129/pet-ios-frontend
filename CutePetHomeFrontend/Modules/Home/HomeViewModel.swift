//
//  HomeViewModel.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {

    // MARK: - 输出

    // 轮播图数据
    let bannerItems = BehaviorRelay<[BannerItem]>(value: [])

    // 功能入口数据
    let functionItems = BehaviorRelay<[FunctionItem]>(value: [])

    // 养宠知识数据
    let petKnowledgeItems = BehaviorRelay<[KnowledgeItem]>(value: [])



    // MARK: - 私有属性

    private let disposeBag = DisposeBag()

    // MARK: - 初始化

    init() {
        fetchBanners()
        setupMockData() // 暂时保留其他模拟数据
    }

    // MARK: - 公共方法

    func refreshData() {
        // 从后端获取轮播图数据
        fetchBanners()

        // 暂时保留其他模拟数据
        let mockFunctions = createMockFunctions()
        functionItems.accept(mockFunctions)

        let mockKnowledge = createMockKnowledge()
        petKnowledgeItems.accept(mockKnowledge)
    }

    // MARK: - 私有方法

    // 从后端获取轮播图数据
    func fetchBanners() {
        print("开始获取轮播图数据...")
        NetworkManager.shared.request(PetAPI.getBanners)
            .subscribe(
                onNext: { [weak self] (banners: [BannerItem]) in
                    guard let self = self else { return }
                    // 更新轮播图数据
                    self.bannerItems.accept(banners)
                    print("成功获取轮播图数据: \(banners.count) 条")

                    // 打印每个轮播图的详细信息
                    for (index, banner) in banners.enumerated() {
                        print("轮播图[\(index)]: id=\(banner.id), title=\(banner.title), imageUrl=\(banner.imageUrl)")
                    }
                },
                onError: { error in
                    print("获取轮播图数据失败: \(error.localizedDescription)")
                    // 加载失败时使用本地模拟数据作为备份
                    self.loadLocalBanners()
                }
            )
            .disposed(by: disposeBag)
    }

    // 加载本地轮播图数据（作为网络请求失败的备份）
    private func loadLocalBanners() {
        print("加载本地轮播图数据...")

        // 检查本地图片资源是否存在
        let imageNames = ["banner_1", "banner_2", "banner_3"]
        for name in imageNames {
            if Bundle.main.url(forResource: name, withExtension: "jpg") != nil {
                print("本地图片资源存在: \(name).jpg")
            } else {
                print("警告: 本地图片资源不存在: \(name).jpg")
            }
        }

        // 使用完整的网络URL作为备份，确保图片能够显示
        let localBanners = [
            BannerItem(id: 1, title: "宠物健康月，免费体检",
                      imageUrl: "https://petshome.oss-cn-beijing.aliyuncs.com/banner/banner1.jpg",
                      linkUrl: "", sort: 1, status: 1),
            BannerItem(id: 2, title: "新品狗粮上市",
                      imageUrl: "https://petshome.oss-cn-beijing.aliyuncs.com/banner/banner2.jpg",
                      linkUrl: "", sort: 2, status: 1),
            BannerItem(id: 3, title: "猫咪美容特惠",
                      imageUrl: "https://petshome.oss-cn-beijing.aliyuncs.com/banner/banner3.jpg",
                      linkUrl: "", sort: 3, status: 1)
        ]
        bannerItems.accept(localBanners)
        print("已加载 \(localBanners.count) 条本地轮播图数据")
    }

    private func setupMockData() {
        // 设置功能入口模拟数据
        let mockFunctions = createMockFunctions()
        functionItems.accept(mockFunctions)

        // 设置养宠知识模拟数据
        let mockKnowledge = createMockKnowledge()
        petKnowledgeItems.accept(mockKnowledge)
    }

    // 创建功能入口模拟数据
    private func createMockFunctions() -> [FunctionItem] {
        return [
            FunctionItem(id: "1", title: "宠物商城", icon: "cart.fill", color: "#FF9500"),
            FunctionItem(id: "2", title: "健康服务", icon: "heart.fill", color: "#FF2D55"),
            FunctionItem(id: "3", title: "美容洗护", icon: "sparkles", color: "#5856D6"),
            FunctionItem(id: "4", title: "宠友社区", icon: "person.2.fill", color: "#4CD964")
        ]
    }

    // 创建养宠知识模拟数据
    private func createMockKnowledge() -> [KnowledgeItem] {
        return [
            KnowledgeItem(id: "1", title: "如何正确给猫咪洗澡", imageUrl: "knowledge_1", summary: "猫咪洗澡有讲究，这些步骤要注意...", author: "猫咪专家", readCount: 1280),
            KnowledgeItem(id: "2", title: "狗狗饮食的五大禁忌", imageUrl: "knowledge_2", summary: "这些食物千万不要给狗狗吃...", author: "宠物营养师", readCount: 2341),
            KnowledgeItem(id: "3", title: "新手养宠必读指南", imageUrl: "knowledge_3", summary: "第一次养宠物，这些事情你必须知道...", author: "萌宠之家", readCount: 3562)
        ]
    }
}

// MARK: - 数据模型

/// 轮播图数据模型
struct BannerItem: Codable {
    let id: Int
    let title: String
    let imageUrl: String
    let linkUrl: String
    let sort: Int?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, imageUrl, linkUrl, sort, status
    }
}

/// 功能入口数据模型
struct FunctionItem {
    let id: String
    let title: String
    let icon: String
    let color: String
}

/// 养宠知识数据模型
struct KnowledgeItem {
    let id: String
    let title: String
    let imageUrl: String
    let summary: String
    let author: String
    let readCount: Int
}


