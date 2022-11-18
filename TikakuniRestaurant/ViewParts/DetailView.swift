//
//  DetailView.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI


// MARK: - お店の詳細情報を表示
struct DetailView: View {
        
    // お店の位置情報を取得するクラスを定義
    @State private var region: MKCoordinateRegion
    
    // お店の位置情報
    var place: [IdentifiablePlace]
    
    //DetailViewで使用する変数を管理するクラスを定義
    var detailViewData: DetailViewData
    
    // MapViewで表示する縮尺
    let delta: CLLocationDegrees = 0.02
    
    // CardViewから読み込み
    init(shop: Shop) {
        
        // DetailViewで使用する変数をクラスで一元管理
        self.detailViewData = DetailViewData(name: shop.name!, access: shop.access!, shopOpen: shop.shopOpen!, url: URL(string: shop.photo.pc.l!)!, lat: shop.lat!, lng: shop.lng!)
        
        self.region = MKCoordinateRegion(
            //Mapの中心の緯度経度
            center: CLLocationCoordinate2D(latitude: shop.lat!,
                                           longitude: shop.lng!),
            //表示領域の縮尺
            span: MKCoordinateSpan(latitudeDelta: self.delta,
                                   longitudeDelta: self.delta)
        )
        
        self.place = [IdentifiablePlace(lat: shop.lat!, long: shop.lng!)]
    }
    
    // HomeViewから読み込み
    init(favoriteShop: FavoriteShop) {
        
        // DetailViewで使用する変数をクラスで一元管理
        self.detailViewData = DetailViewData(name: favoriteShop.name!, access: favoriteShop.access!, shopOpen: favoriteShop.shopOpen!, url: URL(string: favoriteShop.url!)!, lat: favoriteShop.lat, lng: favoriteShop.lng)

        self.region = MKCoordinateRegion(
            //Mapの中心の緯度経度
            center: CLLocationCoordinate2D(latitude: favoriteShop.lat,
                                           longitude: favoriteShop.lng),
            //表示領域の縮尺
            span: MKCoordinateSpan(latitudeDelta: self.delta,
                                   longitudeDelta: self.delta)
        )

        // お店の位置情報
        self.place = [IdentifiablePlace(lat: favoriteShop.lat, long: favoriteShop.lng)]
    }
    
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: CGFloat.miniSpace)
        
            // お店の名前
            Text(self.detailViewData.name)
                .fontWeight(.semibold)
                .font(.system(size: 20))
            
            // サムネイル画像
            AsyncImage(url: self.detailViewData.url) { image in
                image.resizable()
                    .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
            } placeholder: {
                ProgressView()
            }
            
            // MARK: 詳細情報
            HStack {
                Spacer().frame(width: CGFloat.middleSpace)
                VStack {
                    
                    // お店の名前
                    Text(self.detailViewData.name)
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                        .frame(width: UIScreen.main.bounds.width-40, alignment: .leading)
                    
                    // お店へのアクセス
                    HStack(spacing: CGFloat.miniSpace) {
                        Image("mapPin")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(self.detailViewData.access)
                        Spacer()
                    }
                    
                    // お店の営業時間
                    HStack(spacing: CGFloat.miniSpace) {
                        Image(systemName: "clock")
                            .frame(width: 20, height: 20)
                        Text(self.detailViewData.shopOpen)
                        Spacer()
                    }
                }
                Spacer().frame(width: CGFloat.middleSpace)
            }
            
            // お店の位置をマップ上にピンを刺して表示
            Map(coordinateRegion: $region,
                //Mapの操作の指定
                interactionModes: .pan,
                //現在地の表示
                showsUserLocation: false,
                //マーカーの指定
                annotationItems: place) { place in
                MapMarker(coordinate: place.location,
                          tint: Color.red)
                
            }.ignoresSafeArea()
        }
    }
}


// MARK: - DetailViewで使用する変数を管理
class DetailViewData {
    
    // お店の名前
    let name: String
    
    // お店へのアクセス
    let access: String
    
    // お店の営業時間
    let shopOpen: String
    
    // サムネイル画像を取得するためのURL
    let url: URL
    
    // お店の緯度
    let lat: Double
    
    // お店の経度
    let lng: Double
    
    init(name: String, access: String, shopOpen: String, url: URL, lat: Double, lng: Double) {
        self.name = name
        self.access = access
        self.shopOpen = shopOpen
        self.url = url
        self.lat = lat
        self.lng = lng
    }
}


// MARK: - ピンの構造体を定義
struct IdentifiablePlace: Identifiable {
    
    // 一意な値を生成
    let id: UUID
    
    // 位置情報を格納
    let location: CLLocationCoordinate2D
    
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}
