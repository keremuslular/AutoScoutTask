//
//  Car.swift
//  autoscouttask
//
//  Created by Kerem Uslular on 28.02.2023.
//

import Foundation

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
}

struct Seller: Codable, Hashable {
    let type: String
    let phone: String
    let city: String
}
