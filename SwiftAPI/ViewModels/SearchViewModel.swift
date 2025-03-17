//
//  SearchViewModel.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [EbayItem] = []
    @Published var isLoading: Bool = false
    @Published var averageListedPrice: Double = 0
    @Published var totalActiveListings: Int = 0
    @Published var averageSoldPrice: Double = 0
    @Published var totalSoldCompletedListings: Int = 0
    @Published var sellThroughRate: Double? = nil

    func fetchResults() {
        guard !searchText.isEmpty else { return }

        isLoading = true
        EbayAPIService.shared.searchItems(query: searchText) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.results = response.activeListings
                    self.averageListedPrice = Double(response.averageListedPrice) ?? 0
                    self.totalActiveListings = response.totalActiveListings
                    self.averageSoldPrice = response.averageSoldPrice
                    self.totalSoldCompletedListings = response.totalSoldCompletedListings
                    self.sellThroughRate = response.sellThroughRate
                case .failure(let error):
                    print("Error fetching eBay results: \(error.localizedDescription)")
                }
            }
        }
    }
}
