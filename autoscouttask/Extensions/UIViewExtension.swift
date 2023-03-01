//
//  UIViewExtension.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 1.03.2023.
//

import UIKit

extension UIView {
    func applyCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func applyBorderWidth(_ width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
