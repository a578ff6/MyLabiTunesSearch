//
//  StoreItemListTableViewController.swift
//  MyLabiTunesSearch
//
//  Created by 曹家瑋 on 2023/11/1.
//

import UIKit

@MainActor
class StoreItemListTableViewController: UITableViewController {

    // MARK: - Outlets
    
    // 輸入關鍵字查找商品。
    @IBOutlet weak var searchBar: UISearchBar!
    // 讓使用者選擇商品類型。
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    
    /// 用這個 StoreItemController 來進行網路請求，負責根據搜尋條件獲取對應的商品資料。
    let storeItemController = StoreItemController()
    
    /// 存放商品資料
    var items = [StoreItem]()
    
    // 存放的是根據 IndexPath 進行圖片加載任務的對應關係。
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    // 查詢選項包含的媒體類型。
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    struct PropertyKeys {
        static let Item = "Item"
    }
    
    // MARK: - Data Fetching

    // 當使用者在 search bar 輸入文字並點擊搜尋按鈕時會被觸發
    func fetchMatchingItems() {
        // 先清空目前的商品陣列
        self.items = []
        // 重新載入表格視圖以反映清空操作
        self.tableView.reloadData()
        
        // 從 search bar 獲取搜尋條件，若無則設為空字串
        let searchTerm = searchBar.text ?? ""
        // 根據 Segmented Contorller 的選擇來設定媒體類型
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        // 檢查搜尋條件是否為空
        if !searchTerm.isEmpty {
            // 設定查詢參數
            let query = [
                "term": searchTerm,
                "media": mediaType,
                "lang": "en_us",
                "limit": "20"
            ]
            
            Task {
                do {
                    // 使用 storeItemController 來根據 query 獲取商品
                    let items = try await storeItemController.fetchItems(matching: query)
                    // 如果成功，將結果設定到 self.items 並在主線程上重新載入表格視圖
                    self.items = items
                    self.tableView.reloadData()
                } catch {
                    // 若失敗，則在控制台上輸出錯誤訊息
                    print(error)
                }
            }
            
        }
    }

    // 設定表格視圖單元格的內容
    func configure(cell: ItemCell, forItemAt indexPath: IndexPath) {
        
        // 從資料陣列中取得對應indexPath的商品資料
        let item = items[indexPath.row]
        
        // 將單元格的名稱設定為商品項目的名稱
        cell.name = item.name
        // 將單元格的artist設定為商品項目的artist名稱
        cell.artist = item.artist
        // 先將單元格的artworkImage設定為nil，稍後會透過網路請求來取得圖片
        cell.artworkImage = nil
        
        // 初始化網路任務來加載商品的 artworkImage
        // 同時在 imageLoadTasks 字典中記錄這個任務，這樣如果 cell 不顯示時可以取消任務
        imageLoadTasks[indexPath] = Task {
            do {
                // 嘗試異步加載圖片
                let image = try await storeItemController.fetchImage(from: item.artworkURL)
                // 如果加載成功，將加載到的圖片設定給單元格
                cell.artworkImage = image
            } catch {
                print("Error fetching image: \(error)")
            }
            
            // 不論加載成功或失敗，任務完成後將該indexPath的記錄從字典中移除
            imageLoadTasks[indexPath] = nil
        }
    }

    
    // 當 SegmentedControl 選項變更時，觸發商品匹配搜尋。
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.Item, for: indexPath) as? ItemCell else {
            fatalError("The dequeued cell is not an instance of ItemCell.")
        }

        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    
    // MARK: - Table view delegate
    // 當 cell 被選中後，立即取消其選中狀態，讓cell選中後的高亮狀態消失。
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
    // 會在一個 cell 即將不再顯示在表格視圖中時被呼叫。
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 如果該 cell 對應的圖片加載任務存在，則取消這個任務
        // 這樣做可以避免在單元格已經滾動出視野時繼續加載圖片，從而節省資料傳輸和資源
        imageLoadTasks[indexPath]?.cancel()
    }

}

// MARK: - Extension

// 擴展 StoreItemListTableViewController，遵從 UISearchBarDelegate 協定
extension StoreItemListTableViewController: UISearchBarDelegate {
    
    // 當搜尋按鈕被點擊時觸發，執行商品匹配搜尋並收起鍵盤
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}


