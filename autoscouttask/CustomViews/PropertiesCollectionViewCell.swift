//
//  PropertiesCollectionViewCell.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 2.03.2023.
//

import Reusable

class PropertiesCollectionViewCell: UICollectionViewCell, Reusable {
    var property: String = "" {
        didSet {
            label.text = property
        }
    }
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16.0)
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        applyBorderWidth(0.5, color: .black)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
