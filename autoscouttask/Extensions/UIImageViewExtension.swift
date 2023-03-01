//
//  UIImageViewExtension.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 1.03.2023.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, contentMode mode: ContentMode = .scaleAspectFit, loadEnded: (() -> ())? = nil) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        loadEnded?()
                    }
                }
            }
        }
    }
    
    func loadImage(from link: String, contentMode mode: ContentMode = .scaleAspectFit, loadEnded: (() -> ())? = nil) {
        guard let url = URL(string: link) else { return }
        loadImage(from: url, contentMode: mode, loadEnded: loadEnded)
    }
}
