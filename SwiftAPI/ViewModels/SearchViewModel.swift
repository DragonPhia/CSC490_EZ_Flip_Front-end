//
//  SearchViewModel.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [EbayItem] = []
    @Published var isLoading = false
    @Published var averageListedPrice: Double = 0.0
    @Published var totalActiveListings: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    // Function to preprocess the search query
    func preprocessQuery(query: String) -> String {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedQuery = trimmedQuery.lowercased()
        
        // Remove punctuation (anything that's not alphanumeric or space)
        let cleanedQuery = normalizedQuery.replacingOccurrences(of: "[^a-zA-Z0-9 ]", with: "", options: .regularExpression)
        
        return cleanedQuery
    }

    func fetchResults() {
        guard !searchText.isEmpty else {
            return
        }
        
        isLoading = true
        
        // Preprocess the search text before sending the query
        let normalizedQuery = preprocessQuery(query: searchText)
        
        EbayAPIService.fetchItems(query: normalizedQuery)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching data: \(error)")
                }
                self.isLoading = false
            }, receiveValue: { response in
                // Set the results
                self.results = response.activeListings

                // Log the imageUrl for each item
                for item in self.results {
                    if let imageUrl = item.image.imageUrl {
                        print("Fetched imageUrl: \(imageUrl)") // Logging the imageUrl
                    } else {
                        print("No image URL available for item: \(item.title)")
                    }
                } // <-- Closing the 'for' loop here

                // Set the other values
                self.averageListedPrice = Double(response.averageListedPrice) ?? 0.0
                self.totalActiveListings = response.totalActiveListings
            })
            .store(in: &cancellables)
    }
}
