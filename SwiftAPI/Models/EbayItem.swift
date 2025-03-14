//
//  EbayItem.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation

struct EbayResponseWrapper: Codable {
    let activeListings: [EbayItem]
}

struct EbayItem: Identifiable, Codable {
    let id: String
    let title: String
    let price: Price
    let imageUrl: String?
    let itemWebUrl: String
    let condition: String
    let seller: Seller?
    let categories: [Category]
    
    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case title
        case price
        case imageUrl = "image.imageUrl" // Handling the nested image field
        case itemWebUrl = "itemWebUrl"
        case condition
        case seller
        case categories
    }
    
    struct Price: Codable {
        let value: String
        let currency: String
    }

    struct Seller: Codable {
        let username: String?
        let feedbackScore: Int?
    }

    struct Category: Codable {
        let categoryId: String
        let categoryName: String
    }
}
