//
//  CoffeeShopVM.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import Foundation
import RxSwift

class CoffeeShopVM {
    var bag: DisposeBag = .init()
    var service: YelpServiceType
    
    enum ViewEvent {
        case viewLoaded
        case fetchNextPage
    }
    
    enum ViewEffect {
        case showLoading(Bool)
        case showBottomLoading(Bool)
        case showNextData([BusinessModel])
    }
    
    enum Output {
        case dataLoadedResult([BusinessModel])
        case dataFetchErrorResult
        case shouldLoadResult(Bool)
        case loadingNextPageResult(Bool)
    }
    
    private(set) lazy var viewEffect: Observable<ViewEffect> = {
        viewResult
            .compactMap { result in
                switch result {
                case .dataLoadedResult(let data):
                    return .showNextData(data)
                case .dataFetchErrorResult:
                    return nil
                case .shouldLoadResult(let isLoading):
                    return .showLoading(isLoading)
                case .loadingNextPageResult(let isLoading):
                    return .showBottomLoading(isLoading)
                }
            }
    }()
    
    private lazy var viewResult: Observable<Output> = {
        Observable.merge([
            fetchDataResult,
            fetchNextPageResult
        ]).share(replay: 1, scope: .whileConnected)
    }()
    
    private var pageOffset: Int = 0
    private var isLoading: Bool = false
    
    let viewEvent: PublishSubject<ViewEvent> = .init()
    
    init(service: YelpServiceType = YelpService()) {
        self.service = service
    }
    
    func updatePageOffset(by count: Int) {
        pageOffset += count
    }
}

extension CoffeeShopVM {
    private var fetchDataResult: Observable<Output> {
        viewEvent
            .flatMap { [weak self] event -> Observable<Output> in
                guard
                    let self,
                    case .viewLoaded = event
                else { return .never()
                }
                return fetchBusinesses(offset: 0)
                    .flatMap { [weak self] businessModels -> Observable<Output> in
                        self?.updatePageOffset(by: businessModels.count)
                        return .from([.dataLoadedResult(businessModels), .shouldLoadResult(false)])
                    }
                    .catch { error in
                        return .from([.dataFetchErrorResult, .shouldLoadResult(false)])
                    }
                    .startWith(.shouldLoadResult(true))
            }
    }
    
    private var fetchNextPageResult: Observable<Output> {
        viewEvent.flatMap { [weak self] event -> Observable<Output> in
            guard
                let self,
                case .fetchNextPage = event,
                !isLoading
            else {
                return .never()
            }
            isLoading = true
            return self.fetchBusinesses(offset: self.pageOffset)
                .flatMap { [weak self] businessModels -> Observable<Output> in
                    self?.isLoading = false
                    self?.updatePageOffset(by: businessModels.count)
                    return .from([
                        .dataLoadedResult(businessModels),
                        .loadingNextPageResult(false)
                    ])
                }
                .catch { [weak self] error in
                    self?.isLoading = false
                    return .from([
                        .dataFetchErrorResult,
                        .loadingNextPageResult(false)
                    ])
                }
                .startWith(.loadingNextPageResult(true))
        }
    }
    
    private func fetchBusinesses(offset: Int) -> Observable<[BusinessModel]> {
        service.fetchBusiness(with: .init(
            location: "410 Townsend Street, San Francisco, CA",
            term: "coffee",
            limit: 10,
            offSet: offset
        ))
    }
}
