//
//  StoreSearcherVM.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/15/24.
//

import UIKit
import RxSwift

class CoffeeShopVC: UIViewController {
    typealias ViewEffect = CoffeeShopVM.ViewEffect
    
    private var bag: DisposeBag = .init()
    private var viewModel: CoffeeShopVM
    
    private var dataSource: UITableViewDiffableDataSource<Section, AnyHashable>?
    
    enum Section {
        case main
        case loading
    }
    
    enum LoadingModel {
        case loading
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        var activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private lazy var activityIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(viewModel: CoffeeShopVM = CoffeeShopVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Coffee Shops"
        
        bind()
        setupUI()
        setupTableView()
        viewModel.viewEvent.on(.next(.viewLoaded))
    }
    
    private func setupUI() {
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        activityIndicatorView.isHidden = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.bringSubviewToFront(activityIndicatorView)
    }
    
    private func activityIndicator(shouldShow: Bool) {
        activityIndicatorView.isHidden = !shouldShow
        if shouldShow {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
    }
}

extension CoffeeShopVC {
    private func bind() {
        viewModel.viewEffect
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] effect in
            self?.onEffect(effect)
        }.disposed(by: bag)
    }
    
    private func onEffect(_ effect: ViewEffect) {
        switch effect {
        case .showLoading(let isLoading):
            activityIndicator(shouldShow: isLoading)
        case .showBottomLoading(let isLoading):
            showLoadingCell(isLoading: isLoading)
        case .showNextData(let models):
            updateTableView(with: models)
        }
    }
}

extension CoffeeShopVC {
    func setupTableView() {
        tableView.register(CoffeeShopCell.self, forCellReuseIdentifier: CoffeeShopCell.identifier)
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.identifier)
        tableView.delegate = self
        setupdataSource()
    }
    
    private func setupdataSource() {
        dataSource = UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                switch item {
                case let model as BusinessModel:
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: CoffeeShopCell.identifier,
                        for: indexPath
                    ) as? CoffeeShopCell else {
                        preconditionFailure()
                    }
                    
                    cell.configure(with: model)
                    
                    return cell
                case _ as LoadingModel:
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: LoadingCell.identifier,
                        for: indexPath
                    ) as? LoadingCell else {
                        preconditionFailure()
                    }
                    cell.startAnimating()
                    return cell
                default:
                    fatalError("unknown type")
                }
            }
        )
        tableView.dataSource = dataSource
        var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable> = .init()
        snapshot.appendSections([.main, .loading])
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func updateTableView(with data: [BusinessModel]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems(data, toSection: .main)
        
        guard let snapshot = snapshot else { return }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func showLoadingCell(isLoading: Bool) {
        let snapshot = dataSource?.snapshot()
        guard var snapshot = snapshot else { return }
        
        if isLoading {
            snapshot.appendItems([LoadingModel.loading], toSection: .loading)
        } else {
            snapshot.deleteItems([LoadingModel.loading])
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
}

extension CoffeeShopVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.numberOfRows(inSection: 0) < indexPath.row + 5 {
            viewModel.viewEvent.on(.next(.fetchNextPage))
        }
    }
}
