//
//  NetworkManager.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation
import RxSwift

enum NetworkManagerError: Error {
    case serverError
    case clientError(Int)
    case responseError
    case missingData
    case malformedData(Error)
}

protocol NetworkManagerType {
    func fetchData <T: Codable> (
        _ type: T.Type,
        api: API
    ) -> Observable<T>
    func fetchData(
        urlRequest: URLRequest
    ) -> Observable<Data>
}

class NetworkManager: NetworkManagerType {
    func fetchData <T: Codable> (
        _ type: T.Type,
        api: API
    ) -> Observable<T> {
        Observable<T>.create { [weak self] observer in
            guard 
                let self,
                let urlReq = api.urlReq
            else { return Disposables.create() }
            let disposable = fetchData(urlRequest: urlReq)
                .subscribe(
                    onNext: { data in
                        do {
                            let decodedData = try JSONDecoder().decode(T.self, from: data)
                            observer.onNext(decodedData)
                        } catch {
                            observer.onError(NetworkManagerError.malformedData(error))
                        }
                    }
                ) { error in
                    observer.onError(error)
                }
            return disposable
        }
    }
    
    func fetchData(
        urlRequest: URLRequest
    ) -> Observable<Data> {
        Observable<Data>.create { observer in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let _ = error {
                    observer.onError(NetworkManagerError.serverError)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    observer.onError(NetworkManagerError.responseError)
                    return
                }
                
                switch response.statusCode {
                case 400..<500:
                    observer.onError(NetworkManagerError.clientError(response.statusCode))
                default:
                    break
                }
                
                guard let data = data else {
                    observer.onError(NetworkManagerError.missingData)
                    return
                }
                
                observer.onNext(data)
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
