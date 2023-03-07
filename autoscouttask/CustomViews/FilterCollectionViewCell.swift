//
//  FilterCollectionViewCell.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 5.03.2023.
//

import UIKit
import Reusable

class FilterCollectionViewCell: UICollectionViewCell, Reusable {
    var filter: Filter? {
        didSet {
            guard let filter = filter else { return }
            prepare(with: filter)
        }
    }
    
    var containerView: UIView = {
        let view = UIView()
        view.applyBorderWidth(0.7, color: .black)
        view.applyCornerRadius(10.0)
        return view
    }()
    
    var filterLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 14.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(filterLabel)
        filterLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.filterLabel.text = ""
        self.containerView.backgroundColor = .clear
    }
    
    func prepare(with filter: Filter) {
        if filter.changedTitle != "" {
            self.filterLabel.text = filter.changedTitle
            self.containerView.backgroundColor = .systemYellow.withAlphaComponent(0.5)
        } else {
            self.filterLabel.text = filter.category.rawValue.capitalized
            self.containerView.backgroundColor = .clear
        }
    }
    
    func changeLabel(with text: String) {
        filterLabel.text = text
    }
}
