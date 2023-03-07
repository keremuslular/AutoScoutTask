//
//  FilterSelectionView.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 5.03.2023.
//

import UIKit
import RangeSeekSlider
import DropDown

protocol FilterSelectionViewDelegate: NSObjectProtocol {
    func filterSelectionViewDidSavedChangedValue(_ view: FilterSelectionView, of filter: Filter)
    func filterSelectionViewDidReturnToDefault(_ view: FilterSelectionView, of filter: Filter)
}

class FilterSelectionView: UIView {
    weak var delegate: FilterSelectionViewDelegate?
    
    var filter: Filter? {
        didSet {
            guard let filter = filter else { return }
            prepare(with: filter)
        }
    }
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCornerRadius(30.0)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("CONFIRM", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.applyBorderWidth(0.7, color: .black)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("CANCEL", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.applyBorderWidth(0.7, color: .black)
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        let attributedText = NSAttributedString(string: "Reset to default", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        button.setAttributedTitle(attributedText, for: .normal)
        return button
    }()
    
    var slider: RangeSeekSlider?
    var dropDown: DropDown?
    var fromDatePicker: UIDatePicker?
    var toDatePicker: UIDatePicker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [overlayView, containerView].forEach(addSubview)
        
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancel)))
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30.0)
            make.center.equalToSuperview()
            make.height.equalTo(300.0)
        }
                
        [titleLabel, confirmButton, cancelButton, resetButton].forEach(containerView.addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50.0)
            make.leading.trailing.equalToSuperview()
        }
        
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        confirmButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.trailing.equalTo(containerView.snp.centerX)
            make.height.equalTo(50.0)
        }
        
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.leading.equalTo(containerView.snp.centerX)
            make.height.equalTo(50.0)
        }
        
        resetButton.addTarget(self, action: #selector(resetToDefault), for: .touchUpInside)
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).offset(-20.0)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(50.0)
            make.height.equalTo(20.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(with filter: Filter) {
        titleLabel.text = filter.category.rawValue.uppercased()
        switch filter.type {
        case .selection:
            var selectionData: [String]
            let colors: [UIColor] = [.white, .black, .brown, .red, .orange, .yellow, .green, .blue, .purple]
            
            if filter.category == .fuel {
                selectionData = ["Gasoline", "Diesel", "Hybrid", "Electric"]
            } else {
                selectionData = colors.map { $0.name! }
            }
            selectionData.insert(Constant.selection, at: 0)
            
            let selectionButton = UIButton()
            selectionButton.setTitle(Constant.selection, for: .normal)
            selectionButton.setTitleColor(.black, for: .normal)
            selectionButton.titleLabel?.font = .systemFont(ofSize: 18)
            selectionButton.applyBorderWidth(0.7, color: .black)
            selectionButton.applyCornerRadius(10.0)
            selectionButton.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
            
            containerView.addSubview(selectionButton)
            
            selectionButton.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(30.0)
                make.height.equalTo(30.0)
            }
            
            let dropDown = DropDown()
            dropDown.anchorView = selectionButton
            dropDown.dataSource = selectionData
            
            dropDown.selectionAction = { (index, item) in
                selectionButton.setTitle(item, for: .normal)
                if filter.category == .colour {
                    selectionButton.backgroundColor = colors.first(where: { $0.name == item })?.withAlphaComponent(0.3)
                }
            }
            
            var selected: String = Constant.selection
            if filter.category == .fuel {
                if let fuel = UserDefaults.standard.string(forKey: DefaultsKey.fuelType.rawValue) {
                    selected = fuel
                    selectionButton.setTitle(fuel, for: .normal)
                } else {
                    UserDefaults.standard.set(selected, forKey: DefaultsKey.fuelType.rawValue)
                }
            } else {
                if let colour = UserDefaults.standard.string(forKey: DefaultsKey.colour.rawValue) {
                    selected = colour
                    selectionButton.setTitle(colour, for: .normal)
                    selectionButton.backgroundColor = colors.first(where: { $0.name == colour })?.withAlphaComponent(0.3)
                } else {
                    UserDefaults.standard.set(selected, forKey: DefaultsKey.colour.rawValue)
                }
            }
            
            dropDown.selectRow(at: selectionData.firstIndex(of: selected))

            self.dropDown = dropDown
        case .range:
            let slider = RangeSeekSlider(frame: .zero)
            slider.colorBetweenHandles = .systemYellow
            slider.handleColor = .systemYellow
            slider.handleBorderColor = .systemYellow
            slider.initialColor = .systemYellow
            slider.minLabelFont = .systemFont(ofSize: 16)
            slider.maxLabelFont = .systemFont(ofSize: 16)
            slider.minLabelColor = .black
            slider.maxLabelColor = .black
            slider.enableStep = true
            slider.step = 1000

            var minValue: CGFloat = Constant.rangeMin
            var maxValue: CGFloat = filter.category == .price ? Constant.rangeMaxPrice : Constant.rangeMaxMileage
            
            if filter.category == .price {
                if UserDefaults.standard.float(forKey: DefaultsKey.minPrice.rawValue) != 0.0 {
                    minValue = CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.minPrice.rawValue))
                } else {
                    UserDefaults.standard.set(minValue, forKey: DefaultsKey.minPrice.rawValue)
                }
                
                if UserDefaults.standard.float(forKey: DefaultsKey.maxPrice.rawValue) != 0.0 {
                    maxValue = CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.maxPrice.rawValue))
                } else {
                    UserDefaults.standard.set(maxValue, forKey: DefaultsKey.maxPrice.rawValue)
                }
            } else {
                if UserDefaults.standard.float(forKey: DefaultsKey.minMileage.rawValue) != 0.0 {
                    minValue = CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.minMileage.rawValue))
                } else {
                    UserDefaults.standard.set(minValue, forKey: DefaultsKey.minMileage.rawValue)
                }
                
                if UserDefaults.standard.float(forKey: DefaultsKey.maxMileage.rawValue) != 0.0 {
                    maxValue = CGFloat(UserDefaults.standard.float(forKey: DefaultsKey.maxMileage.rawValue))
                } else {
                    UserDefaults.standard.set(maxValue, forKey: DefaultsKey.maxMileage.rawValue)
                }
            }
            
            slider.minValue = Constant.rangeMin
            slider.maxValue = filter.category == .price ? Constant.rangeMaxPrice : Constant.rangeMaxMileage
            slider.selectedMinValue = minValue
            slider.selectedMaxValue = maxValue
            
            containerView.addSubview(slider)
            
            slider.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(30.0)
                make.height.equalTo(30.0)
            }
            self.slider = slider
        case .date:
            var dateFrom = Constant.dateFrom
            var dateTo = Constant.dateTo
            
            if let from = UserDefaults.standard.object(forKey: DefaultsKey.registrationFrom.rawValue) as? Date {
                dateFrom = from
            } else {
                UserDefaults.standard.set(dateFrom, forKey: DefaultsKey.registrationFrom.rawValue)
            }
            
            if let to = UserDefaults.standard.object(forKey: DefaultsKey.registrationTo.rawValue) as? Date {
                dateTo = to
            } else {
                UserDefaults.standard.set(dateTo, forKey: DefaultsKey.registrationTo.rawValue)
            }
            
            let fromPicker = UIDatePicker()
            fromPicker.timeZone = .current
            fromPicker.preferredDatePickerStyle = .wheels
            fromPicker.datePickerMode = .date
            fromPicker.setDate(dateFrom, animated: false)
            
            let toPicker = UIDatePicker()
            toPicker.timeZone = .current
            toPicker.preferredDatePickerStyle = .wheels
            toPicker.datePickerMode = .date
            toPicker.setDate(dateTo, animated: false)
            
            let fromLabel = UILabel(frame: .zero)
            fromLabel.font = .boldSystemFont(ofSize: 14.0)
            fromLabel.textAlignment = .left
            fromLabel.text = "FROM:"
            
            let toLabel = UILabel(frame: .zero)
            toLabel.font = .boldSystemFont(ofSize: 14.0)
            toLabel.textAlignment = .left
            toLabel.text = "TO:"
            
            let dateContainer = UIView()
            containerView.addSubview(dateContainer)
            
            dateContainer.snp.makeConstraints { make in
                make.center.leading.trailing.equalToSuperview()
                make.height.equalTo(100.0)
            }
            
            [fromLabel, fromPicker, toLabel, toPicker].forEach(dateContainer.addSubview)
            
            fromLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().inset(10.0)
                make.bottom.equalTo(dateContainer.snp.centerY)
                make.width.equalTo(50.0)
            }
            
            toLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview().inset(10.0)
                make.top.equalTo(dateContainer.snp.centerY)
                make.width.equalTo(50.0)
            }
            
            fromPicker.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview()
                make.leading.equalTo(fromLabel.snp.trailing)
                make.bottom.equalTo(dateContainer.snp.centerY)
            }
            
            toPicker.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview()
                make.leading.equalTo(toLabel.snp.trailing)
                make.top.equalTo(dateContainer.snp.centerY)
            }
            
            self.fromDatePicker = fromPicker
            self.toDatePicker = toPicker
        }
    }
    
    func saveState() {
        guard var filter = self.filter else { return }
        switch filter.category {
        case .price:
            guard let slider = slider else { return }
            
            UserDefaults.standard.set(slider.selectedMinValue, forKey: DefaultsKey.minPrice.rawValue)
            UserDefaults.standard.set(slider.selectedMaxValue, forKey: DefaultsKey.maxPrice.rawValue)
            
            if slider.selectedMinValue != Constant.rangeMin || slider.selectedMaxValue != Constant.rangeMaxPrice {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let minString = numberFormatter.string(from: NSNumber(value: Int(slider.selectedMinValue))) ?? ""
                let maxString = numberFormatter.string(from: NSNumber(value: Int(slider.selectedMaxValue))) ?? ""

                filter.changedTitle = "Price: \(minString) - \(maxString)"
                delegate?.filterSelectionViewDidSavedChangedValue(self, of: filter)
            } else {
                delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
            }
        case .mileage:
            guard let slider = slider else { return }

            UserDefaults.standard.set(slider.selectedMinValue, forKey: DefaultsKey.minMileage.rawValue)
            UserDefaults.standard.set(slider.selectedMaxValue, forKey: DefaultsKey.maxMileage.rawValue)
            
            if slider.selectedMinValue != Constant.rangeMin || slider.selectedMaxValue != Constant.rangeMaxMileage {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let minString = numberFormatter.string(from: NSNumber(value: Int(slider.selectedMinValue))) ?? ""
                let maxString = numberFormatter.string(from: NSNumber(value: Int(slider.selectedMaxValue))) ?? ""
                
                filter.changedTitle = "Mileage: \(minString) - \(maxString)"
                delegate?.filterSelectionViewDidSavedChangedValue(self, of: filter)
            } else {
                delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
            }
        case .fuel:
            guard let dropDown = dropDown else { return }
            
            UserDefaults.standard.set(dropDown.selectedItem, forKey: DefaultsKey.fuelType.rawValue)
            if dropDown.selectedItem != Constant.selection {
                filter.changedTitle = dropDown.selectedItem!
                delegate?.filterSelectionViewDidSavedChangedValue(self, of: filter)
            } else {
                delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
            }
        case .colour:
            guard let dropDown = dropDown else { return }

            UserDefaults.standard.set(dropDown.selectedItem, forKey: DefaultsKey.colour.rawValue)
            if dropDown.selectedItem != Constant.selection {
                filter.changedTitle = dropDown.selectedItem!
                delegate?.filterSelectionViewDidSavedChangedValue(self, of: filter)
            } else {
                delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
            }
        case .registration:
            guard let fromDatePicker = fromDatePicker else { return }
            guard let toDatePicker = toDatePicker else { return }
            
            UserDefaults.standard.set(fromDatePicker.date, forKey: DefaultsKey.registrationFrom.rawValue)
            UserDefaults.standard.set(toDatePicker.date, forKey: DefaultsKey.registrationTo.rawValue)
            
            if fromDatePicker.date != Constant.dateFrom || toDatePicker.date != Constant.dateTo {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-yyyy"
                let fromString = dateFormatter.string(from: fromDatePicker.date)
                let toString = dateFormatter.string(from: toDatePicker.date)
                
                filter.changedTitle = "Registration: \(fromString) - \(toString)"
                delegate?.filterSelectionViewDidSavedChangedValue(self, of: filter)
            } else {
                delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
            }
        }
    }
    
    @objc func resetToDefault() {
        guard let filter = self.filter else { return }
        switch filter.category {
        case .price:
            UserDefaults.standard.set(Constant.rangeMin, forKey: DefaultsKey.minPrice.rawValue)
            UserDefaults.standard.set(Constant.rangeMaxPrice, forKey: DefaultsKey.maxPrice.rawValue)
        case .mileage:
            UserDefaults.standard.set(Constant.rangeMin, forKey: DefaultsKey.minMileage.rawValue)
            UserDefaults.standard.set(Constant.rangeMaxMileage, forKey: DefaultsKey.maxMileage.rawValue)
        case .fuel:
            UserDefaults.standard.set(Constant.selection, forKey: DefaultsKey.fuelType.rawValue)
        case .colour:
            UserDefaults.standard.set(Constant.selection, forKey: DefaultsKey.colour.rawValue)
        case .registration:
            UserDefaults.standard.set(Constant.dateFrom, forKey: DefaultsKey.registrationFrom.rawValue)
            UserDefaults.standard.set(Constant.dateTo, forKey: DefaultsKey.registrationTo.rawValue)
        }
        delegate?.filterSelectionViewDidReturnToDefault(self, of: filter)
        cancel()
    }
    
    @objc func confirm() {
        saveState()
        removeFromSuperview()
    }
    
    @objc func cancel() {
        removeFromSuperview()
    }
    
    @objc func showDropDown() {
        dropDown?.show()
    }
}
