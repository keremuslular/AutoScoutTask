//
//  CarCardCollectionViewCell.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 28.02.2023.
//

import UIKit
import SnapKit
import Reusable

class CarCardCollectionViewCell: UICollectionViewCell, Reusable {
    
    var car: Car? {
        didSet {
            guard let car = car else { return }
            prepare(with: car)
        }
    }
    
    let imageCarouselView = ImageCarouselView()
    let infoContainerView = UIView(frame: .zero)
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        return label
    }()
    
    let detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white.withAlphaComponent(0.9)
        contentView.applyCornerRadius(10.0)
        
        [imageCarouselView, infoContainerView].forEach(contentView.addSubview)
        
        imageCarouselView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150.0)
        }
        
        infoContainerView.snp.makeConstraints { make in
            make.top.equalTo(imageCarouselView.snp.bottom).offset(5.0)
            make.leading.trailing.bottom.equalToSuperview().inset(5.0)
        }
        
        [titleLabel, priceLabel, detailStackView].forEach(infoContainerView.addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5.0)
            make.leading.trailing.equalToSuperview()
        }
        
        detailStackView.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(5.0)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(with car: Car) {
        imageCarouselView.images = car.images?.compactMap { $0 }
        titleLabel.text = "\(car.make) \(car.model)"
        priceLabel.text = "€ \(car.price).-"
        
        // Set used properties in detail
        let milage = "\(car.mileage) km"
        let fuel = car.fuel
        let modelline = "Modelline: \(car.modelline ?? "-")"
        let colour = "Colour: \(car.colour ?? "-")"
        let firstRegistration = "Registration: \(car.firstRegistration ?? "-")"
        let description = car.description
        
        let detailStrings = [milage, fuel, modelline, colour, firstRegistration, description]
        
        detailStrings.forEach { string in
            let label: UILabel = {
                let lbl = UILabel(frame: .zero)
                lbl.font = .systemFont(ofSize: 10.0)
                lbl.textAlignment = .left
                lbl.numberOfLines = 0
                lbl.text = string
                return lbl
            }()
            self.detailStackView.addArrangedSubview(label)
        }
    }
}
