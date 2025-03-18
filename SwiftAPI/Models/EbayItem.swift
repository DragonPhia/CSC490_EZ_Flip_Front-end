//
//  EbayItem.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation

struct EbayResponseWrapper: Codable {
    let activeListings: [EbayItem]
    let averageListedPrice: Double
    let totalActiveListings: Int
    let averageSoldPrice: Double
    let totalSoldCompletedListings: Int
    let sellThroughRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case activeListings
        case averageListedPrice
        case totalActiveListings
        case averageSoldPrice
        case totalSoldCompletedListings
        case sellThroughRate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activeListings = try container.decodeIfPresent([EbayItem].self, forKey: .activeListings) ?? []
        averageListedPrice = Double(try container.decodeIfPresent(String.self, forKey: .averageListedPrice) ?? "0") ?? 0.0
        totalActiveListings = try container.decodeIfPresent(Int.self, forKey: .totalActiveListings) ?? 0
        averageSoldPrice = try container.decodeIfPresent(Double.self, forKey: .averageSoldPrice) ?? 0.0
        totalSoldCompletedListings = try container.decodeIfPresent(Int.self, forKey: .totalSoldCompletedListings) ?? 0
        sellThroughRate = try container.decodeIfPresent(Double.self, forKey: .sellThroughRate)
    }
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
        case imageUrl
        case itemWebUrl
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(Price.self, forKey: .price)
        itemWebUrl = try container.decode(String.self, forKey: .itemWebUrl)
        condition = try container.decode(String.self, forKey: .condition)
        seller = try container.decodeIfPresent(Seller.self, forKey: .seller)
        categories = try container.decodeIfPresent([Category].self, forKey: .categories) ?? []
        
        // Handling nested image field safely
        if let imageContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .imageUrl) {
            imageUrl = try imageContainer.decodeIfPresent(String.self, forKey: .imageUrl)
        } else {
            imageUrl = nil
        }
    }
}
