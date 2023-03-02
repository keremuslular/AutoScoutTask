//
//  Car.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 28.02.2023.
//

import UIKit

struct Car: Codable, Hashable {
    let id: Int
    let make: String
    let model: String
    let price: Int
    let mileage: Int
    let fuel: String
    let description: String
    let colour: String?
    let firstRegistration: String?
    let modelline: String?
    let images: [CarImage]?
    let seller: Seller?
}

struct CarImage: Codable, Hashable {
    let url: String
    
    // Storing data of the image because the images from the endpoint gives random urls each time it's called
    var pngData: Data?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        
        if let data = try? Data(contentsOf: URL(string: url)!) {
            if let image = UIImage(data: data) {
                pngData = image.pngData()!
            }
        }
    }
}

struct Seller: Codable, Hashable {
    let type: String
    let phone: String
    let city: String
}
