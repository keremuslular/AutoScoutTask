//
//  Constant.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 6.03.2023.
//

import Foundation

struct Constant {
    static var rangeMin: CGFloat = 0.0
    static var rangeMax: CGFloat = 250000.0
    
    static var selection = "Any"
    
    static var dateFrom = Date(timeIntervalSince1970: 0)
    
    static var dateTo: Date {
        let dateString = "01.01.2024"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.date(from: dateString)!
    }
}
