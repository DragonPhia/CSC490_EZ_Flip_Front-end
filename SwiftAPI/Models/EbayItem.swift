//
//  EbayItem.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation

struct EbayItem: Identifiable, Codable {
    var id: String { itemId }
    let itemId: String
    let title: String
    let image: ImageWrapper
    let price: Price
    let seller: Seller
    let condition: String
    let itemHref: String
    let categories: [Category] // Added categories property
}

struct ImageWrapper: Codable {
    let imageUrl: String?
}

struct Price: Codable {
    let value: String
    let currency: String
}

struct Seller: Codable {
    let username: String
    let feedbackPercentage: String
    let feedbackScore: Int
}

// New model for category
struct Category: Codable {
    let categoryName: String
}
