//
//  UIColorExtension.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 6.03.2023.
//

import UIKit

extension UIColor {
    var name: String? {
        switch self {
        case .red:
            return "Red"
        case .orange:
            return "Orange"
        case .yellow:
            return "Yellow"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .purple:
            return "Purple"
        case .brown:
            return "Brown"
        case .black:
            return "Black"
        case .white:
            return "White"
        default:
            return nil
        }
    }
}
