//
//  Utils.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import CoreFoundation
import UIKit
import SwiftUI

// MARK: Viewでよく使用するスペースを定義
extension CGFloat {
    
    // FavoriteView表示で使用するスペース
    static let favoriteViewLength: CGFloat = UIScreen.main.bounds.width/3
    static let favoriteButtonLength: CGFloat = 30
    
    // CardViewで使用するスペース
    static let cardSideSpace: CGFloat = 40
    static let cardHeight: CGFloat = 150
    
    // よく使うスペースを定義
    static let miniSpace: CGFloat = 10
    static let middleSpace: CGFloat = 20
    static let middleLargeSpace: CGFloat = 40
    static let LargeSpace: CGFloat = 60
}


// MARK: 追加で使用するカスタムフォントを定義
extension Font {
    
    static func yosugara(size: CGFloat) -> Font {
        return Font.custom("yosugara", size: size)
    }
}
