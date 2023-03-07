//
//  DetailViewController.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 1.03.2023.
//

import UIKit
import Reusable

class DetailViewController: UIViewController {
    var car: Car? {
        didSet {
            guard let car = car else { return }
            prepare(with: car)
        }
    }
    
    var propertyStrings: [String] = [] {
        didSet {
            propertiesCollectionView.reloadData()
        }
    }
    
    let imageCarouselView = ImageCarouselView()
    let infoContainerView = UIView(frame: .zero)
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textAlignment = .center
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 24.0)
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16.0)
        label.textAlignment = .center
        return label
    }()
    
    lazy var propertiesCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: generateDetailsLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        return cv
    }()
    
    lazy var contactButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(contactButtontapped), for: .touchUpInside)
        button.setImage(UIImage(named: "callButton"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "DETAILS"
        
        view.backgroundColor = .white.withAlphaComponent(0.9)
        
        [imageCarouselView, infoContainerView].forEach(view.addSubview)
        
        imageCarouselView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.bounds.width)
        }
        
        infoContainerView.snp.makeConstraints { make in
            make.top.equalTo(imageCarouselView.snp.bottom).offset(10.0)
            make.leading.trailing.bottom.equalToSuperview().inset(10.0)
        }
        
        [titleLabel, priceLabel, descriptionLabel, propertiesCollectionView, contactButton].forEach(infoContainerView.addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
            make.leading.trailing.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(5.0)
            make.leading.trailing.equalToSuperview()
        }
        
        propertiesCollectionView.register(cellType: PropertiesCollectionViewCell.self)
        propertiesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(        descriptionLabel.snp.bottom).offset(5.0)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contactButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10.0)
            make.width.height.equalTo(70.0)
        }
    }
    
    func prepare(with car: Car) {
        var images: [UIImage] = []
        if let carImages = car.images, carImages.count > 0 {
            images = carImages.compactMap { UIImage(data: $0.pngData!) }
        } else {
            images = [UIImage(named: "carPlaceholder")!]
        }
        imageCarouselView.images = images
        
        titleLabel.text = "\(car.make) \(car.model)"
        priceLabel.text = "€ \(car.price).-"
        descriptionLabel.text = car.description
        
        let mileage = "\(car.mileage) km"
        let fuel = car.fuel
        let modelline = "Modelline: \(car.modelline ?? "-")"
        let colour = "Colour: \(car.colour ?? "-")"
        let firstRegistration = "Registration: \(car.firstRegistration ?? "-")"
        let city = "City: " + (car.seller?.city ?? "-")
        
        propertyStrings = [mileage, fuel, modelline, colour, firstRegistration, city]
        
        contactButton.isHidden = car.seller?.phone == nil
    }
    
    func generateDetailsLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(30.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @objc func contactButtontapped() {
        if let car = car, let phone = car.seller?.phone {
            if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return propertyStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PropertiesCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.property = propertyStrings[indexPath.item]
        return cell
    }
}
