//
//  StoreItem.swift
//  MyLabiTunesSearch
//
//  Created by 曹家瑋 on 2023/11/1.
//

import Foundation

// 定義一個符合 Codable 協定的 StoreItem 結構
struct StoreItem: Codable {
    let name: String
    let artist: String
    var kind: String
    var description: String
    var artworkURL: URL
    
    // 使用 enum 定義 Codable 的鍵值對應
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case description           // 主要的 description key
        case artworkURL = "artworkUrl100"
    }
    
    // 額外的 key 列舉，用於特定情境
    enum AdditionalKeys: String, CodingKey {
        case longDescription
    }
    
    // 自定義的解碼器，用於從 JSON 解碼為 StoreItem
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: CodingKeys.name)
        artist = try values.decode(String.self, forKey: CodingKeys.artist)
        kind = try values.decode(String.self, forKey: CodingKeys.kind)
        artworkURL = try values.decode(URL.self, forKey: CodingKeys.artworkURL)
        
        // 嘗試解碼 description，如果無法解碼，則使用 longDescription
        if let description = try? values.decode(String.self, forKey: CodingKeys.description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            description = (try? additionalValues.decode(String.self, forKey: AdditionalKeys.longDescription)) ?? ""
        }
    }
}

// 定義一個符合 Codable 協定的 SearchResponse 結構，其內含多個 StoreItem 的陣列
struct SearchResponse: Codable {
    let results: [StoreItem]
}

