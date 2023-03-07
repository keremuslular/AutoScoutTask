//
//  FilterCollectionView.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 4.03.2023.
//

import UIKit
import Reusable
import RangeSeekSlider

protocol FilterCollectionViewDelegate: NSObjectProtocol {
    func filterCollectionViewDidSelect(_ view: FilterCollectionView, with filter: Filter)
    func filterCollectionViewDidResetAllFilters(_ view: FilterCollectionView)
}

class FilterCollectionView: UIView {
    weak var delegate: FilterCollectionViewDelegate?
    
    enum Section {
        case filters
    }
    
    // Using DiffableDataSource may not make sense for this case, but I always like to plan for the future, as the data from the url can/should change in a live environment
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    lazy var dataSource = makeDataSource()

    var filters = [
        Filter(with: .price),
        Filter(with: .mileage),
        Filter(with: .fuel),
        Filter(with: .colour),
        Filter(with: .registration)
    ] {
        didSet {
            applySnapshot()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        return cv
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("RESET", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.applyBorderWidth(0.7, color: .black)
        button.applyCornerRadius(10.0)
        button.backgroundColor = .black.withAlphaComponent(0.8)
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [resetButton, collectionView, lineView].forEach(addSubview)
        
        resetButton.addTarget(self, action: #selector(resetAllFilters), for: .touchUpInside)
        resetButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10.0)
            make.bottom.equalToSuperview().inset(12.0)
            make.width.equalTo(60.0)
        }

        collectionView.register(cellType: FilterCollectionViewCell.self)
        collectionView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(resetButton.snp.leading).offset(-10.0)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }
        
        applySnapshot(animatingDifferences: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, dataItem) -> UICollectionViewCell? in
            if let filter = dataItem as? Filter {
                let cell: FilterCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.filter = filter
                return cell
            } else {
                return nil
            }
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.filters])
        snapshot.appendItems(filters)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    @objc func resetAllFilters() {
        DefaultsKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        filters = [
            Filter(with: .price),
            Filter(with: .mileage),
            Filter(with: .fuel),
            Filter(with: .colour),
            Filter(with: .registration)
        ]
        delegate?.filterCollectionViewDidResetAllFilters(self)
    }
}

extension FilterCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filterCollectionViewDidSelect(self, with: filters[indexPath.item])
    }
}
