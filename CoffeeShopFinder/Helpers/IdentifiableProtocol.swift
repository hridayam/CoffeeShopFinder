//
//  IdentifiableProtocol.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/16/24.
//

import Foundation

protocol IdentifiableProtocol {
    static var identifier: String { get }
}

extension IdentifiableProtocol {
    static var identifier: String {
        String(describing: self)
    }
}
