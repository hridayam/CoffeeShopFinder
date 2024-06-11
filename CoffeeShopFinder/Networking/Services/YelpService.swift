//
//  YelpService.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation
import RxSwift

protocol YelpServiceType {
    func fetchBusiness(
        with data: SearchModel
    ) -> Observable<[BusinessModel]>
}

class YelpService: YelpServiceType {
    private let networkManager: NetworkManagerType
    
    init(networkManager: NetworkManagerType = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchBusiness(
        with data: SearchModel
    ) -> Observable<[BusinessModel]> {
        networkManager.fetchData (
            BusinessListModel.self,
            api: YelpAPI.businessSearch(data)
        )
        .map { businessList in
                businessList.businesses
        }
        .catch { error in
            throw error
        }
    }
}
