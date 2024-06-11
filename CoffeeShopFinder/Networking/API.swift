//
//  API.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation

protocol API {
    var urlReq: URLRequest? { get }
    func getURL(queryItems: [URLQueryItem]?) -> URL?
}
