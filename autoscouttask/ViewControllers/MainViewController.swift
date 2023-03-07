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
    var originalCars: [Car] = []
    var cars: [Car] = [] {
        willSet {
            animatingDifferences = !cars.isEmpty
        }
        didSet {
            applySnapshot(animatingDifferences: animatingDifferences)
        }
    }
    
    lazy var filterCollectionView: FilterCollectionView = {
        let cv = FilterCollectionView(frame: .zero)
        cv.delegate = self
        return cv
    }()
    
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
        [filterCollectionView, collectionView].forEach(view.addSubview)
        
        filterCollectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(52.0)
        }
        
        collectionView.register(cellType: CardCollectionViewCell.self)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(filterCollectionView.snp.bottom).offset(3.0)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
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
        section.interGroupSpacing = 20.0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @objc func fetchCars() {
        guard let url = URL(string: "https://private-fe87c-simpleclassifieds.apiary-mock.com/") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        print("Fetching with url: \(url)")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedData = try? JSONDecoder().decode([Car].self, from: data) {
                    DispatchQueue.main.async {
                        print("Ended fetch")
                        self.originalCars = decodedData
                        self.cars = decodedData
                        self.refreshControl.endRefreshing()
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
        
        filterCollectionView.resetAllFilters()
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
    
    func checkFilters() {
        let minPrice = UserDefaults.standard.float(forKey: DefaultsKey.minPrice.rawValue) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.minPrice.rawValue)) : Constant.rangeMin
        let maxPrice = UserDefaults.standard.float(forKey: DefaultsKey.maxPrice.rawValue) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.maxPrice.rawValue)) : Constant.rangeMax
        
        let minMilage = UserDefaults.standard.float(forKey: DefaultsKey.minMilage.rawValue) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.minMilage.rawValue)) : Constant.rangeMin
        let maxMilage = UserDefaults.standard.float(forKey: DefaultsKey.maxMilage.rawValue) != 0.0 ? CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.maxMilage.rawValue)) : Constant.rangeMax
        
        let fuelType = UserDefaults.standard.string(forKey: DefaultsKey.fuelType.rawValue) ?? Constant.selection
        
        let colour = UserDefaults.standard.string(forKey: DefaultsKey.colour.rawValue) ?? Constant.selection
        
        let registrationFrom = UserDefaults.standard.object(forKey: DefaultsKey.registrationFrom.rawValue) as? Date ?? Constant.dateFrom
        let registrationTo = UserDefaults.standard.object(forKey: DefaultsKey.registrationTo.rawValue) as? Date ?? Constant.dateTo
        
        var indexesToRemove: Set<Int> = []
        
        for (index, car) in originalCars.enumerated() {
            if !(minPrice...maxPrice).contains(CGFloat(car.price)) {
                indexesToRemove.insert(index)
                continue
            }
            
            if !(minMilage...maxMilage).contains(CGFloat(car.mileage)) {
                indexesToRemove.insert(index)
                continue
            }
            
            if !(fuelType == Constant.selection || fuelType == car.fuel) {
                indexesToRemove.insert(index)
                continue
            }
            
            if let carColour = car.colour {
                if !(colour == Constant.selection || colour == carColour) {
                    indexesToRemove.insert(index)
                    continue
                }
            }
            
            if let registeration = car.firstRegistration {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-yyyy"
                if let date = dateFormatter.date(from: registeration), !(date.isBetween(registrationFrom, and: registrationTo)) {
                    indexesToRemove.insert(index)
                    continue
                }
            }
        }
        
        cars = originalCars.enumerated()
            .filter { !indexesToRemove.contains($0.offset) }
            .map { $0.element }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController = DetailViewController()
        detailViewController.car = cars[indexPath.item]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension MainViewController: FilterCollectionViewDelegate {
    func filterCollectionViewDidSelect(_ view: FilterCollectionView, with filter: Filter) {
        let filterSelectionView = FilterSelectionView(frame: .zero)
        filterSelectionView.filter = filter
        filterSelectionView.delegate = self
        self.view.addSubview(filterSelectionView)
        filterSelectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func filterCollectionViewDidResetAllFilters(_ view: FilterCollectionView) {
        checkFilters()
    }
}

extension MainViewController: FilterSelectionViewDelegate {
    func filterSelectionViewDidSavedChangedValue(_ view: FilterSelectionView, of filter: Filter) {
        if let index = filterCollectionView.filters.firstIndex(where: { $0.category == filter.category }) {
            filterCollectionView.filters[index] = filter
            checkFilters()
        }
    }
    
    func filterSelectionViewDidReturnToDefault(_ view: FilterSelectionView, of filter: Filter) {
        if let index = filterCollectionView.filters.firstIndex(where: { $0.category == filter.category }) {
            filterCollectionView.filters[index] = Filter(with: filter.category)
            checkFilters()
        }
    }
}
