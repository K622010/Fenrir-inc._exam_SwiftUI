//
//  SearchExecute.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import CoreLocation
import Alamofire


// MARK: - 現在地の取得・更新とAPIを用いた検索
class SearchExecute: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var center: CLLocationCoordinate2D!
    
    // 検索半径の候補を格納
    let searchScale: [CLLocationDistance] = [300, 500, 1000, 2000, 3000]
    
    // 検索半径の初期値に1000mを選択(searchScaleの3番目)
    @Published var selectedSearchScaleNumber: Int = 3
    
    // 緯度
    @Published var latitudeNow: CLLocationDegrees = 34.6557981011818
    
    // 経度
    @Published var longitudeNow: CLLocationDegrees = 135.49490185564184
    
    // ロケーションマネージャ
    @Published var locationManager: CLLocationManager?
    
    // ボタンのタップ情報
    @Published var isButtonTapped = false
    
    var shops: [Shop] = []
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // LocationManagerの初期設定
    func setupLocationManager() {
        
        // 位置情報を保管するためのクラスを定義
        locationManager = CLLocationManager()
        
        // 位置サービスの認証に必要
        locationManager!.delegate = self

        // 権限をリクエスト
        locationManager!.requestWhenInUseAuthorization()

        // マネージャの設定
        let status = CLLocationManager().authorizationStatus

        // ステータスごとの処理
        if status == .authorizedWhenInUse {
            locationManager!.delegate = self
            locationManager!.startUpdatingLocation()
        }
    }
    
    // 現在地を更新
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // 現在地の緯度・経度を格納
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude

        // 位置情報を格納する
        self.latitudeNow = latitude!
        self.longitudeNow = longitude!
        
    }
    
    // 検索条件に合致するお店を検索
    func search() {
        
        // 検索条件をSearchOptionクラスに格納
        let searchOption = SearchOption(latitudenow: latitudeNow, longtitudeNow: longitudeNow, range: selectedSearchScaleNumber)

        // デコーダー
        let decoder: JSONDecoder = JSONDecoder()
        
        // ホットペッパーAPIへリクエストを送信
        AF.request(searchOption.returnRequestWords()).responseJSON { response in
            switch response.result {
                
            // 送信に成功した場合
            case .success:
                do {
                    // 受信結果を格納
                    let articles = try decoder.decode(Welcome.self, from: response.data!)
                    
                    // ResultViewへ画面遷移
                    self.transitionResultView(articles: articles)
                } catch {
                    print("デコードに失敗しました")
                }
            
            // 送信に失敗した場合
            case .failure(let error):
                print("error", error)
            }
        }
    }
    
    // ボタンがタップされたことを認識し、ResultViewに画面遷移する
    private func transitionResultView(articles: Welcome) {
        self.shops = articles.results.shop
        self.isButtonTapped = true
    }
}
