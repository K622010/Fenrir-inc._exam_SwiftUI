//
//  FavoriteShop+CoreDataProperties.swift
//  TikakuniRestaurant
//
//  Created by 江越瑠一 on 2022/11/15.
//
//

import Foundation
import CoreData


extension FavoriteShop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteShop> {
        return NSFetchRequest<FavoriteShop>(entityName: "FavoriteShop")
    }

    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var url: String?
    @NSManaged public var access: String?
    @NSManaged public var shopOpen: String?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double

}

extension FavoriteShop : Identifiable {

}
