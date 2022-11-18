//
//  ContentView.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import SwiftUI
import CoreData
import CoreLocation
import _MapKit_SwiftUI


// MARK: - メイン画面
struct HomeView: View {
    
    // FavoriteViewのコンテキストを取得
    @Environment(\.managedObjectContext) private var viewContext
    
    // 現在保存されているFavoriteShopのリストを取得
    @FetchRequest(
        entity: FavoriteShop.entity(),
        sortDescriptors: [],
        animation: .default
    ) var fetchedFavoriteShopList: FetchedResults<FavoriteShop>
    
    // DetailViewへの画面遷移を行う際に使用
    @State var isButtonPushed = false
    
    // CardViewへの画面遷移を行う際に使用
    @ObservedObject var searchExecute = SearchExecute()

    var body: some View {
        NavigationView {
            ZStack {
                
                // 背景
                Color("background")
                    .ignoresSafeArea()
            
                VStack {
                    
                    // ResultViewに画面遷移
                    NavigationLink(destination: ResultView(shops: searchExecute.shops), isActive: $searchExecute.isButtonTapped) {
                        EmptyView()
                    }
                    
                    // タイトル表示
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.green)
                        Text("現在地から近いお店を探す")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black)
                    }
                    
                    // 探すお店の半径を指定する(m)
                    HStack {
                        
                        // 300m, 500m, 1000m, 2000m, 3000mの中で検索半径を変更
                        Picker("", selection: $searchExecute.selectedSearchScaleNumber) {
                            ForEach(1...5, id: \.self) { s in
                                Text(String(Int(searchExecute.searchScale[s-1]))+"M")
                            }
                            .pickerStyle(.menu)
                        }
                        
                        // 検索ボタン
                        Button(action: {
                            searchExecute.search()
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.green)
                                    .cornerRadius(5)
                                    .frame(width: 50, height: 30)
                                Text("検索")
                                    .font(.system(size: 15))
                                    .fontWeight(.light)
                                    .foregroundColor(Color("background"))
                            }
                        }
                    }
                    
                    // 現在地を中心に半径1000mの範囲で地図を表示
                    InputMapView(lat: searchExecute.latitudeNow, lng: searchExecute.longitudeNow, radiusMeters: searchExecute.searchScale[2])
                        .frame(width: UIScreen.main.bounds.width-40, height: UIScreen.main.bounds.width-40)
                    
                    Spacer()
                        .frame(height: CGFloat.middleSpace)
                    
                    Text("お気に入り")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    // お気に入りのお店を横スクロールで表示
                    ScrollView(.horizontal) {
                        HStack(spacing: CGFloat.miniSpace) {
                            
                            // お気に入りの店の数だけループ
                            ForEach(0..<fetchedFavoriteShopList.count, id: \.self) { favoriteShopNumber in
                                if fetchedFavoriteShopList[favoriteShopNumber].isFavorite {
                                    
                                    // FavoriteViewを表示
                                    FavoriteView(favoriteshop: fetchedFavoriteShopList[favoriteShopNumber])
                                        .shadow(radius: 5, x: 5, y: 5)
                                        .padding(CGFloat.miniSpace)

                                        // Viewの非表示時にデータ削除(逆だとエラー発生)
                                        .onDisappear {
                                            viewContext.delete(fetchedFavoriteShopList[favoriteShopNumber])
                                            try? viewContext.save()
                                        }

                                        // タップ判定
                                        .onTapGesture {
                                            self.isButtonPushed.toggle()
                                        }

                                        // DetailViewへ画面遷移
                                        .sheet(isPresented: $isButtonPushed) {
                                            DetailView(favoriteShop: fetchedFavoriteShopList[favoriteShopNumber])
                                        }
                                }
                            }
                            
                            // お気に入りのお店がなかった場合に「No shops」と表示
                            if fetchedFavoriteShopList.count == 0 {
                                Text("No shops")
                                    .font(.system(size: 40))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.gray)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/3+40, alignment: .center)
                            }
                        }
                    }
                }
            }
        }
    }
}


// MARK: - 現在地からの半径1000mを表示
struct InputMapView: View {
    
    // 現在地の情報を取得するクラスを定義
    @State private var region: MKCoordinateRegion
    
    var place: [IdentifiablePlace]
    
    init(lat: Double, lng: Double, radiusMeters: CLLocationDistance) {

        self.region = MKCoordinateRegion(
            //Mapの中心の緯度経度
            center: CLLocationCoordinate2D(latitude: lat,
                                           longitude: lng),
            //緯度の表示領域(m)
            latitudinalMeters: radiusMeters,
            //経度の表示領域(m)
            longitudinalMeters: radiusMeters
        )
        
        // 現在地を格納
        self.place = [IdentifiablePlace(lat: lat, long: lng)]
    }
    
    var body: some View {
        
        Map(coordinateRegion: $region,
            // Mapの操作の指定
            interactionModes: .pan,
            
            // 現在地の表示
            showsUserLocation: true,
            
            // 現在地にフォーカスを合わせる
            userTrackingMode: .constant(MapUserTrackingMode.follow)
          
        )
        // 丸に変形
        .cornerRadius(UIScreen.main.bounds.width/2)
    }
}


// MARK: - お気に入りに登録した企業一覧を表示
struct FavoriteView: View {
    
    // お気に入りのお店情報をFavoriteShop型で受け取る
    @ObservedObject var favoriteShop: FavoriteShop
    
    // FavoriteViewのコンテキストを取得
    @Environment(\.managedObjectContext) private var viewContext
    
    init(favoriteshop: FavoriteShop) {
        self.favoriteShop = favoriteshop
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                
                // 店の画像を読み込み
                AsyncImage(url: URL(string: favoriteShop.url!)) { image in
                    
                    image.resizable()
                        .frame(width: CGFloat.favoriteViewLength, height: CGFloat.favoriteViewLength)
                    
                } placeholder: {
                    
                    // 読み込み中は待機画像を表示
                    ProgressView()
                }
                
                ZStack {
                    
                    // お気に入りボタン
                    Circle()
                        .frame(width: CGFloat.favoriteButtonLength, height: CGFloat.favoriteButtonLength)
                        .foregroundColor(Color.white)
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.yellow)
                        .frame(width: CGFloat.favoriteButtonLength, height: CGFloat.favoriteButtonLength)
                    
                    // お気に入りを解除
                    .onTapGesture {
                        favoriteShop.isFavorite.toggle()
                    }
                    
                }
                // お気に入りボタンをFavoriteViewの右上に配置
                .frame(width: CGFloat.favoriteViewLength-CGFloat.miniSpace, height: CGFloat.favoriteViewLength-CGFloat.miniSpace, alignment: .topTrailing)
            }
            
            // お店の名前を表示
            ZStack {
                Rectangle()
                    .frame(width: CGFloat.favoriteViewLength, height: 40)
                    .foregroundColor(Color.white)
                Text(favoriteShop.name!)
            }
            
        }.cornerRadius(20)
    }
}


// MARK: - Previewでテスト表示
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
