//
//  DateExtension.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 7.03.2023.
//

import Foundation

extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
