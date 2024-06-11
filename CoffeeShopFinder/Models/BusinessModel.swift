//
//  BusinessModel.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation

struct BusinessModel: Codable, Hashable {
    let id: String
    let name: String
    let price: String?
    let imageURL: URL?
    let location: LocationModel
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case imageURL = "image_url"
        case location
    }
}
