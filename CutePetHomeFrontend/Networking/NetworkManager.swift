//
//  NetworkManager.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation
import Alamofire
import Moya
import RxSwift

// 在同一模块中，不需要显式导入APIModels.swift

// MARK: - API定义

/// API接口定义
enum PetAPI {
    // 用户相关
    case login(username: String, password: String)
    case register(username: String, password: String, phone: String)
    case sendVerificationCode(phone: String)
    case verifyCode(phone: String, code: String)
    case getUserInfo
    case updateUserInfo(params: [String: Any])
    case logout

    // 首页相关
    case getBanners
    case getHomeFeeds
    case getKnowledgeArticles(page: Int, size: Int)
    case getLocalActivities(page: Int, size: Int)
    case getUserPosts(page: Int, size: Int)

    // 商城相关
    case getProductCategories
    case getProducts(categoryId: Int?, keyword: String?, page: Int, size: Int)
    case getProductDetail(id: Int)
    case getCartItems
    case addToCart(productId: Int, quantity: Int)
    case updateCartItem(itemId: Int, quantity: Int)
    case removeCartItem(itemId: Int)

    // 宠物相关
    case getPets
    case addPet(params: [String: Any])
    case updatePet(petId: Int, params: [String: Any])
    case deletePet(petId: Int)
}

// MARK: - TargetType协议实现

extension PetAPI: TargetType {
    var baseURL: URL {

        let baseURLString = AppPlist.Server.apiBaseURL
        return URL(string: baseURLString)!
    }

    var path: String {
        // 添加/api前缀
        let apiPrefix = ""

        switch self {
        // 用户相关
        case .login:
            return "\(apiPrefix)/user/login"
        case .register:
            return "\(apiPrefix)/user/register"
        case .sendVerificationCode:
            return "\(apiPrefix)/user/sendVerificationCode"
        case .verifyCode:
            return "\(apiPrefix)/user/verifyCode"
        case .getUserInfo:
            // 使用当前登录用户的ID
            if let userId = UserManager.shared.currentUser?.id {
                return "\(apiPrefix)/user/\(userId)"
            } else {
                return "\(apiPrefix)/user/info"
            }
        case .updateUserInfo:
            return "\(apiPrefix)/user/update"
        case .logout:
            return "\(apiPrefix)/user/logout"

        // 首页相关
        case .getBanners:
            return "\(apiPrefix)/banner/list"
        case .getHomeFeeds:
            return "\(apiPrefix)/home/feeds"
        case .getKnowledgeArticles:
            return "\(apiPrefix)/home/knowledge"
        case .getLocalActivities:
            return "\(apiPrefix)/home/activities"
        case .getUserPosts:
            return "\(apiPrefix)/home/posts"

        // 商城相关
        case .getProductCategories:
            return "\(apiPrefix)/mall/categories"
        case .getProducts:
            return "\(apiPrefix)/mall/products"
        case .getProductDetail(let id):
            return "\(apiPrefix)/mall/products/\(id)"
        case .getCartItems:
            return "\(apiPrefix)/mall/cart"
        case .addToCart:
            return "\(apiPrefix)/mall/cart/add"
        case .updateCartItem(let itemId, _):
            return "\(apiPrefix)/mall/cart/\(itemId)"
        case .removeCartItem(let itemId):
            return "\(apiPrefix)/mall/cart/\(itemId)"

        // 宠物相关
        case .getPets:
            return "\(apiPrefix)/pet/list"
        case .addPet:
            return "\(apiPrefix)/pet/add"
        case .updatePet(let petId, _):
            return "\(apiPrefix)/pet/\(petId)"
        case .deletePet(let petId):
            return "\(apiPrefix)/pet/\(petId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .register, .sendVerificationCode, .verifyCode, .addToCart, .addPet:
            return .post
        case .updateUserInfo, .updateCartItem, .updatePet:
            return .put
        case .removeCartItem, .deletePet, .logout:
            return .delete
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        // POST请求参数
        case .login(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: URLEncoding.queryString)
        case .register(let username, let password, let phone):
            // 创建完整的用户注册对象，包括必要的字段
            let params: [String: Any] = [
                "username": username,
                "password": password,
                "mobile": phone,
                "nickname": username, // 默认使用用户名作为昵称
                "gender": 0 // 默认性别为未知
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .sendVerificationCode(let phone):
            return .requestParameters(parameters: ["mobile": phone], encoding: URLEncoding.queryString)
        case .verifyCode(let phone, let code):
            return .requestParameters(parameters: ["mobile": phone, "code": code], encoding: URLEncoding.queryString)
        case .updateUserInfo(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .addToCart(let productId, let quantity):
            return .requestParameters(parameters: ["productId": productId, "quantity": quantity], encoding: JSONEncoding.default)
        case .updateCartItem(_, let quantity):
            return .requestParameters(parameters: ["quantity": quantity], encoding: JSONEncoding.default)
        case .addPet(let params), .updatePet(_, let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        // GET请求参数
        case .getKnowledgeArticles(let page, let size), .getLocalActivities(let page, let size), .getUserPosts(let page, let size):
            return .requestParameters(parameters: ["page": page, "size": size], encoding: URLEncoding.queryString)
        case .getProducts(let categoryId, let keyword, let page, let size):
            var params: [String: Any] = ["page": page, "size": size]
            if let categoryId = categoryId {
                params["categoryId"] = categoryId
            }
            if let keyword = keyword {
                params["keyword"] = keyword
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        // 无参数请求
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]

        // 对于登录和注册请求，不添加Authorization请求头
        switch self {
        case .login, .register, .sendVerificationCode, .verifyCode:
            return headers
        default:
            // 添加认证Token
            if let token = UserDefaults.standard.string(forKey: AppPlist.StorageKey.userToken) {
                // 检查token是否已经包含"Bearer "前缀
                if token.hasPrefix("Bearer ") {
                    headers["Authorization"] = token
                } else {
                    headers["Authorization"] = "Bearer \(token)"
                }

                // 打印认证头信息，用于调试
                print("Authorization header: \(headers["Authorization"] ?? "none")")
            }
            return headers
        }
    }
}

// MARK: - 网络管理器

class NetworkManager {

    // 单例
    static let shared = NetworkManager()

    // MoyaProvider实例
    private let provider = MoyaProvider<PetAPI>(plugins: [NetworkLoggerPlugin()])

    // 私有初始化方法
    private init() {}

    // MARK: - 请求方法

    /// 发送网络请求
    /// - Parameter target: API目标
    /// - Returns: Observable序列
    func request<T: Codable>(_ target: PetAPI) -> Observable<T> {
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map(ApiResponse<T>.self)
            .map { response in
                // 检查API响应状态码
                guard response.code == 200 else {
                    throw NSError(domain: "API Error", code: response.code, userInfo: [NSLocalizedDescriptionKey: response.message])
                }

                // 返回数据
                if let data = response.data {
                    return data
                } else {
                    throw NSError(domain: "API Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                }
            }
            .asObservable()
    }
}

// API响应模型已移至Models/APIModels.swift
