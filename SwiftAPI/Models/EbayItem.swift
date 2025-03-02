//
//  EbayItem.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation

struct EbayItem: Codable, Identifiable {
    let id: String
    let title: String
    let category: String?
    let price: Price
    let imageUrl: String?
    let itemURL: String

    struct Price: Codable {
        let value: String
        let currency: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "itemId"
        case title
        case category = "primaryCategory"
        case price = "sellingStatus"
        case imageUrl = "galleryURL"
        case itemURL = "viewItemURL"
    }
    
    struct CategoryContainer: Codable {
        let categoryName: [String]?
    }
    
    struct PriceContainer: Codable {
        let currentPrice: [PriceValue]
    }
    
    struct PriceValue: Codable {
        let currencyId: String
        let __value__: String
        
        enum CodingKeys: String, CodingKey {
            case currencyId = "@currencyId"
            case __value__
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent([String].self, forKey: .id)?.first ?? "Unknown"
        title = try container.decodeIfPresent([String].self, forKey: .title)?.first ?? "No Title"
        itemURL = try container.decodeIfPresent([String].self, forKey: .itemURL)?.first ?? "#"

        if let categoryContainer = try? container.decodeIfPresent([CategoryContainer].self, forKey: .category),
           let firstCategory = categoryContainer.first?.categoryName?.first {
            category = firstCategory
        } else {
            category = nil
        }

        if let priceContainer = try? container.decodeIfPresent([PriceContainer].self, forKey: .price),
           let firstPrice = priceContainer.first?.currentPrice.first {
            price = Price(value: firstPrice.__value__, currency: firstPrice.currencyId)
        } else {
            price = Price(value: "0.00", currency: "USD")
        }

        imageUrl = try container.decodeIfPresent([String].self, forKey: .imageUrl)?.first
    }
}

// Updated response structure for better JSON decoding
struct EbayResponseWrapper: Codable {
    let findItemsByKeywordsResponse: [FindItemsResponse]
}

struct FindItemsResponse: Codable {
    let searchResult: [SearchResult]?
}

struct SearchResult: Codable {
    let item: [EbayItem]?
}
