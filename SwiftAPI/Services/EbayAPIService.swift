//
//  APIService.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/27/25.
//

import Foundation
import Combine

struct EbayAPIResponse: Codable {
    let averageListedPrice: String
    let totalActiveListings: Int
    let activeListings: [EbayItem]
}

class EbayAPIService {
    static let baseURL = "https://ezflip.onrender.com/api/search?query="
    
    static func fetchItems(query: String) -> AnyPublisher<EbayAPIResponse, Error> {
        let urlString = baseURL + query
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: EbayAPIResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
