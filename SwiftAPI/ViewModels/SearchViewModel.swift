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
    @Published var loadedItemCount: Int = 20  // Start with 20 items

    private var cancellables = Set<AnyCancellable>()
    
    func preprocessQuery(query: String) -> String {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedQuery = trimmedQuery.lowercased()
        return normalizedQuery.replacingOccurrences(of: "[^a-zA-Z0-9 ]", with: "", options: .regularExpression)
    }

    func fetchResults() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        
        let normalizedQuery = preprocessQuery(query: searchText)
        
        EbayAPIService.fetchItems(query: normalizedQuery)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching data: \(error)")
                }
                self.isLoading = false
            }, receiveValue: { response in
                self.results = response.activeListings
                self.averageListedPrice = Double(response.averageListedPrice) ?? 0.0
                self.totalActiveListings = response.totalActiveListings
                self.loadedItemCount = min(20, self.results.count) // Reset with 20 or less
            })
            .store(in: &cancellables)
    }

    func loadMoreItemsIfNeeded(item: EbayItem) {
        guard let lastLoadedItem = results.prefix(loadedItemCount).last else { return }

        if item.id == lastLoadedItem.id, loadedItemCount < results.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.loadedItemCount = min(self.loadedItemCount + 20, self.results.count)
                self.objectWillChange.send()  // Notify UI of change
            }
        }
    }
}
