//
//  LocationModel.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation

struct LocationModel: Codable, Hashable {
    var displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}
