//
//  API.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation

enum YelpAPI: API {
    private enum Constant {
        static let authHeader = "Authorization"
        static let apiKey = """
                    """
        static let baseURL: String = "https://api.yelp.com/v3/"
        static let bearer = "Bearer"
        static let businessSearchPath: String = "businesses/search"
        static let limit: String = "limit"
        static let location: String = "location"
        static let offset: String = "offset"
        static let term: String = "term"
    }
    
    case businessSearch(SearchModel)
    
    var urlReq: URLRequest? {
        var request: URLRequest
        switch self {
        case .businessSearch(let model):
            let params: [URLQueryItem] = [
                URLQueryItem(name: Constant.location, value: model.location),
                URLQueryItem(
                    name: Constant.term,
                    value: model.term.addingPercentEncoding(
                        withAllowedCharacters: .urlHostAllowed)
                ),
                URLQueryItem(name: Constant.limit, value: .init(model.limit)),
                URLQueryItem(name: Constant.offset, value: .init(model.offSet))
            ]
            
            guard let url = getURL(queryItems: params) else { return nil }
            request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "accept")
        }
        
        return appendAuthHeaders(urlReq: request)
    }
    
    func getURL(queryItems: [URLQueryItem]? = nil) -> URL? {
        guard var urlComps = URLComponents(string: Constant.baseURL+Constant.businessSearchPath) else { return nil }
        urlComps.queryItems = queryItems
        return urlComps.url
    }
    
    private func appendAuthHeaders(urlReq: URLRequest) -> URLRequest {
        var request = urlReq
        request.addValue("\(Constant.bearer) \(Constant.apiKey)", forHTTPHeaderField: Constant.authHeader)
        return request
    }
}
