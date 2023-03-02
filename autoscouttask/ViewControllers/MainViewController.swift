//
//  MainViewController.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 28.02.2023.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    enum Section {
        case grid
    }
    
    // Using DiffableDataSource may not make sense for this case, but I always like to plan for the future, as the data from the url can/should change in a live environment
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    lazy var dataSource = makeDataSource()
    
    var animatingDifferences = true
    var cars: [Car] = [] {
        willSet {
            animatingDifferences = !cars.isEmpty
        }
        didSet {
            applySnapshot(animatingDifferences: animatingDifferences)
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl(frame: .zero)
        rc.tintColor = .systemGray
        rc.addTarget(self, action: #selector(fetchCars), for: .valueChanged)
        return rc
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.refreshControl = refreshControl
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        view.addSubview(collectionView)
        
        collectionView.register(cellType: CardCollectionViewCell.self)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        fetchCars()
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(300.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @objc func fetchCars() {
        guard let url = URL(string: "https://private-fe87c-simpleclassifieds.apiary-mock.com/") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedData = try? JSONDecoder().decode([Car].self, from: data) {
                    DispatchQueue.main.async {
                        self.cars = decodedData
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, dataItem) -> UICollectionViewCell? in
            if let car = dataItem as? Car {
                let cell: CardCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.car = car
                return cell
            } else {
                return nil
            }
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.grid])
        snapshot.appendItems(cars)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.car = cars[indexPath.item]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
