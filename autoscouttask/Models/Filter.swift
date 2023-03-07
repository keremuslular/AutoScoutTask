//
//  Filter.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 5.03.2023.
//

import Foundation

struct Filter: Codable, Hashable {
    enum Category: String, Codable, Hashable {
        case price
        case mileage
        case fuel
        case colour
        case registration
    }
    
    enum SelectionType: String, Codable, Hashable {
        case selection
        case range
        case date
    }
    
    let category: Category
    let type: SelectionType
    
    var changedTitle: String = ""
    
    init(with category: Category) {
        self.category = category
        switch category {
        case .price, .mileage:
            type = .range
        case .fuel, .colour:
            type = .selection
        case.registration:
            type = .date
        }
    }
}
