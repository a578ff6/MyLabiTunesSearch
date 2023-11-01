//
//  StoreItemController.swift
//  MyLabiTunesSearch
//
//  Created by 曹家瑋 on 2023/11/1.
//

import Foundation
import UIKit

class StoreItemController {
    
    // 定義錯誤類型，用來表示在網路請求過程中可能遇到的錯誤情況
    enum StoreItemError: Error, LocalizedError {
        case itemsNotFound          // 當找不到項目時返回的錯誤
        case imageDataMissing       // 當圖片資料缺失時返回的錯誤
    }

    // 根據查詢條件從 iTunes API 獲取資料
    func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
        // 設定要請求的 URL 和 傳入的 query 作為查詢參數
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = query.map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        // 發出異步的網路請求，取得資料和響應
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        // 確保響應是 HTTPURLResponse 類型且狀態碼為 200，否則拋出錯誤
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.itemsNotFound
        }
        
        // 使用 JSONDecoder 解碼資料為 SearchResponse 物件
        let jsonDecoder = JSONDecoder()
        let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
        
        // 回傳解碼後的結果
        return searchResponse.results
        
    }
    
    // 從給定的 URL 異步獲取圖片
    func fetchImage(from url: URL) async throws -> UIImage {
        // 發起異步網路請求，獲取資料和回應
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 確認回應是 HTTPURLResponse 並且狀態碼是 200，否則拋出錯誤
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StoreItemError.imageDataMissing
        }
        
        // 嘗試將獲取的資料轉換為 UIImage，如果無法轉換則拋出錯誤
        guard let image = UIImage(data: data) else {
            throw StoreItemError.imageDataMissing
        }
        
        // 返回 UIImage
        return image
    }
    
}
