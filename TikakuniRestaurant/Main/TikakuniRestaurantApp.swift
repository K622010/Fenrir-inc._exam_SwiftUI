//
//  TikakuniRestaurantApp.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/13.
//

import SwiftUI

@main
struct TikakuniRestaurantApp: App {
    let persistenceController = PersistenceController.shared

    // メイン画面
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
