//
//  SearchOption.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import CoreLocation


// MARK: - 検索条件を格納し、Requestする文字列を生成
class SearchOption {
    
    // 現在地の緯度
    let latitudeNow: CLLocationDegrees
    
    // 現在地の経度
    let longitudeNow: CLLocationDegrees
    
    // 検索する半径
    let range: Int
    
    // APIキー
    let key = "c975c0a7d37860bd"
    
    // 受け取るデータ形式をjsonに指定
    let format = "json"
    
    // 受け取るデータの並び替えをデフォルトに設定
    let order = "4"
    
    init(latitudenow: CLLocationDegrees, longtitudeNow: CLLocationDegrees, range: Int) {
        self.latitudeNow = latitudenow
        self.longitudeNow = longtitudeNow
        self.range = range
    }
    
    // 送信する文字列を生成
    func returnRequestWords() -> String {
        
        // 送信する文字列
        let requestWord = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key="+self.key+"&lat="+String(self.latitudeNow)+"&lng="+String(self.longitudeNow)+"&range="+String(self.range)+"&order="+order+"&format="+format
        
        return requestWord
    }
}


