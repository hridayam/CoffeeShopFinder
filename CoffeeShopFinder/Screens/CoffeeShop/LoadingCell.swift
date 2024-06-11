//
//  LoadingCell.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/17/24.
//

import UIKit


class LoadingCell: UITableViewCell, IdentifiableProtocol {
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        loadingIndicator.startAnimating()
    }
    
    func startAnimating() {
        loadingIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.stopAnimating()
    }
}
