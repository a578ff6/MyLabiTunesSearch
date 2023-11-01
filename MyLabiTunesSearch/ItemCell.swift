//
//  ItemCell.swift
//  MyLabiTunesSearch
//
//  Created by 曹家瑋 on 2023/11/1.
//

import UIKit

// 圖片預留空間：
// 當單元格尚未加載圖片時，可能會先出現在螢幕上。
// 在初始設定中，如果 artworkImage 是 nil，單元格會顯示一個預設的系統圖標 "photo" 作為預留空間，
// 這樣可以保證即使圖片還沒載入，單元格也不會是空的。
// 如果沒有設置預留空間，單元格的版面可能會顯示錯亂。

class ItemCell: UITableViewCell {
    var name: String? = nil
    {
        didSet {
            // 當屬性發生變化時，確保更新單元格配置。
            if oldValue != name {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artist: String? = nil
    {
        didSet {
            // 當屬性發生變化時，確保更新單元格配置。
            if oldValue != artist {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artworkImage: UIImage? = nil
    {
        didSet {
            // 當圖片變更時，確保更新單元格配置。
            if oldValue != artworkImage {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = defaultContentConfiguration().updated(for: state)
        
        // 設定內容的文字為項目的name
        content.text = name
        
        // 設定內容的副文字為項目的artist
        content.secondaryText = artist
        
        // 根據 artworkImage 的存在與否，配置內容圖片的顯示屬性
        content.imageProperties.reservedLayoutSize = CGSize(width: 100.0, height: 100.0)
        if let image = artworkImage {
            content.image = image
        } else {
            // 如果 artworkImage 是 nil，則設定內容的圖片為 "photo"
            content.image = UIImage(systemName: "photo")
            // 設定圖標大小和顏色
            content.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 75.0)
            content.imageProperties.tintColor = .lightGray
        }
        
        // 應用最新的配置到內容上
        self.contentConfiguration = content
    }
}

