//
//  File.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import SwiftUI


// MARK: - 検索したお店の情報を縦に並べてScrollViewで表示
struct ResultView: View {
    
    var shops: [Shop]
    
    // 初期化
    init(shops: [Shop]) {
        self.shops = shops
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                
                // 背景
                Color("background")
                
                VStack() {
                    Spacer()
                        .frame(height: CGFloat.LargeSpace)
                    
                    // ページのタイトルを表示
                    Text("検索結果")
                        .foregroundColor(Color.black)
                        .fontWeight(.semibold)
                    
                    Spacer()
                        .frame(height: CGFloat.miniSpace)
                    
                    VStack(spacing: 20) {
                        
                        // 検索したお店の情報
                        ForEach(0..<shops.count) { shopCounter in
                            CardView(shop: shops[shopCounter])
                                .frame(width: UIScreen.main.bounds.width-CGFloat.cardSideSpace, height: 150)
                        }
                        
                        Spacer()
                            .frame(height: CGFloat.miniSpace)
                    }
                }
            }
        }.ignoresSafeArea()
    }
}


// MARK: - 検索結果に表示する項目
struct CardView: View {
    let shop: Shop
    
    // お気に入り登録
    @State var isFavorite: Bool = false
    
    // ボタンのタップ情報
    @State var isButtonPushed: Bool = false

    // FavoriteViewのコンテキストを取得
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var favoriteShopData: FavoriteShop
    
    init(shop: Shop) {
        self.shop = shop
        self.favoriteShopData = FavoriteShop()
    }
    
    var body: some View {
        ZStack {
            
            // お店のサムネイル画像を表示
            AsyncImage(url: URL(string: shop.photo.pc.l!)) { image in
                image.resizable()
                
                    // 画像を拡大してからカットし、画像の歪みを予防
                    .frame(width: UIScreen.main.bounds.width-CGFloat.cardSideSpace, height: UIScreen.main.bounds.width-CGFloat.cardSideSpace)
                    .frame(width: UIScreen.main.bounds.width-CGFloat.cardSideSpace, height: CGFloat.cardHeight)
                    .clipped()
                
                    .contentShape(Rectangle())
                    .cornerRadius(20)
                    .brightness(-0.2)
                    .shadow(radius: 10, y: 10)
                
            } placeholder: {
                ProgressView()
            }.onTapGesture {
                self.isButtonPushed = true
            }
            
            // CardViewをタップすると、DetailViewに遷移
            .sheet(isPresented: $isButtonPushed) {
                DetailView(shop: self.shop)
            }
            
            // MARK: お店の画像と情報を表示
            VStack {
                HStack {
                    Spacer(minLength: CGFloat.LargeSpace)
                    
                    // お店の名前
                    Text(shop.name!)
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 50, alignment: .leading)
                        .fontWeight(.bold)
                        .font(.yosugara(size: 25))
                    
                    Spacer(minLength: CGFloat.miniSpace)
                    
                    // お気に入りボタン
                    ZStack {
                        Circle()
                            .frame(width: CGFloat.favoriteButtonLength, height: CGFloat.favoriteButtonLength)
                            .foregroundColor(Color.white)
                        
                        // お気に入りに登録されている状態のときは、星マークが黄色で表示
                        if self.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.yellow)
                                .frame(width: CGFloat.favoriteButtonLength, height: CGFloat.favoriteButtonLength)
                                .onTapGesture {
                                    
                                    // お気に入りを解除
                                    self.isFavorite.toggle()
                                    
                                    // FavoriteShopクラスから情報を解除
                                    self.deleteFavoriteShop()
                                }
                        }
                        
                        // お気に入りではない状態のときは、星マークが灰色で表示
                        else {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.gray)
                                .frame(width: CGFloat.favoriteButtonLength, height: CGFloat.favoriteButtonLength)
                                .onTapGesture {
                                    
                                    // お気に入りに登録
                                    self.isFavorite.toggle()
                                    
                                    // FavoriteShopクラスに情報を登録
                                    self.addNewFavoriteShop()
                                }
                        }
                    }
                    
                    Spacer(minLength: CGFloat.LargeSpace)
                }
                
                Spacer(minLength: CGFloat.middleLargeSpace)
                
                // お店へのアクセス
                HStack {
                    Spacer()
                        .frame(width: CGFloat.middleLargeSpace)
                    
                    // アクセス情報を表示
                    Text(shop.access!)
                        .foregroundColor(Color.white)
                        .frame(width: 330, height: 50, alignment: .leading)
                        .fontWeight(.semibold)
                        .font(.system(size: 15))
                    
                    Spacer(minLength: CGFloat.middleLargeSpace)
                }
                Spacer()
                    .frame(height: 5)
            }.frame(width: UIScreen.main.bounds.width-CGFloat.cardSideSpace, height: CGFloat.cardHeight)
        }
    }
    
    // FavoriteShopクラスに情報を登録
    func addNewFavoriteShop() {
        self.favoriteShopData = FavoriteShop(context: self.viewContext)
        self.favoriteShopData.name = shop.name
        self.favoriteShopData.url = shop.photo.pc.l
        self.favoriteShopData.shopOpen = shop.shopOpen
        self.favoriteShopData.access = shop.access
        self.favoriteShopData.lat = shop.lat!
        self.favoriteShopData.lng = shop.lng!
        self.favoriteShopData.isFavorite = true
        print(self.favoriteShopData)
        try? viewContext.save()
    }
    
    // FavoriteShopクラスから情報を解除
    func deleteFavoriteShop() {
        viewContext.delete(self.favoriteShopData)
        try? viewContext.save()
    }
}
