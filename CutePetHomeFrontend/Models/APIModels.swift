//
//  APIModels.swift
//  CutePetHomeFrontend
//
//  Created by Developer on 2023/5/20.
//

import Foundation

/// API响应结构
struct ApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    let pagination: Pagination?

    enum CodingKeys: String, CodingKey {
        case code, message, data, pagination
    }
}

/// 分页信息
struct Pagination: Codable {
    let totalPage: Int
    let currentPage: Int
    let pagePieces: Int
    let totalPieces: Int

    enum CodingKeys: String, CodingKey {
        case totalPage = "total_page"
        case currentPage = "current_page"
        case pagePieces = "page_pieces"
        case totalPieces = "total_pieces"
    }
}

/// 空响应，用于处理没有返回数据的API
struct EmptyResponse: Codable {}
