//
//  CoffeeShopCell.swift
//  CoffeeShopFinder
//
//  Created by hridayam bakshi on 5/17/24.
//

import UIKit
import RxSwift

class CoffeeShopCell: UITableViewCell, IdentifiableProtocol {
    private enum Constant {
        static let imageHeight: CGFloat = 200
        static let imageWidth: CGFloat = 150
        static let spacer: CGFloat = 10
        
    }
    let nameLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        return label
    }()
    
    let storeImageView: UIImageView = {
        var view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let priceLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 1
        return label
    }()
    
    let addressLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        return label
    }()
    
    private var disposeBag: DisposeBag = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.addSubview(storeImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            storeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.spacer),
            storeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.spacer),
            storeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.spacer),
            storeImageView.widthAnchor.constraint(equalToConstant: Constant.imageWidth),
            storeImageView.heightAnchor.constraint(equalToConstant: Constant.imageHeight),
            
            storeImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -Constant.spacer),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.spacer),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constant.spacer),
            nameLabel.bottomAnchor.constraint(equalTo: addressLabel.topAnchor, constant: -Constant.spacer),
            
            addressLabel.leadingAnchor.constraint(equalTo: storeImageView.trailingAnchor, constant: Constant.spacer),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constant.spacer),
            addressLabel.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -Constant.spacer),
            
            priceLabel.leadingAnchor.constraint(equalTo: storeImageView.trailingAnchor, constant: Constant.spacer),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constant.spacer),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: Constant.spacer)
        ])
    }
    
    func configure(with model: BusinessModel) {
        if let url = model.imageURL {
            NetworkManager().fetchData(urlRequest: .init(url: url))
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] data in
                    let image = UIImage(data: data)
                    self?.storeImageView.image = image
                })
                .disposed(by: disposeBag)
        }
        
        var address: String = ""
        for addressItem in model.location.displayAddress {
            address.append("\(addressItem)\n")
        }
        addressLabel.text = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        priceLabel.text = model.price
        nameLabel.text = model.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        addressLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        storeImageView.image = nil
        disposeBag = DisposeBag()
    }
}
