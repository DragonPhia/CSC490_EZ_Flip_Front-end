//
//  SearchViewModel.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/1/25.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [EbayItem] = []
    @Published var isLoading: Bool = false

    func fetchResults() {
        guard !searchText.isEmpty else { return }

        isLoading = true
        EbayAPIService.shared.searchItems(query: searchText) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.results = items
                case .failure(let error):
                    print("Error fetching eBay results: \(error.localizedDescription)")
                }
            }
        }
    }
}
