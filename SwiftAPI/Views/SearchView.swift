//
//  SearchView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/26/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var results: [EbayItem] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        TextField("Search for an item...", text: $searchText, onCommit: fetchResults)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.leading)

                        Button(action: fetchResults) {
                            Image(systemName: "magnifyingglass")
                                .padding(10)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 10)

                    ScrollView {
                        if isLoading {
                            ProgressView("Searching...")
                                .padding()
                        } else if results.isEmpty && !searchText.isEmpty {
                            Text("No results found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            LazyVStack {
                                ForEach(results) { item in
                                    HStack {
                                        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFit()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 50, height: 50)
                                        }

                                        VStack(alignment: .leading) {
                                            Text(item.title)
                                                .font(.headline)
                                            Text("\(item.price.currency) \(item.price.value)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.85) // Adjust height dynamically
                }
                .ignoresSafeArea(.keyboard) // Prevents keyboard from pushing the view
            }
            .navigationTitle("Find Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func fetchResults() {
        guard !searchText.isEmpty else { return }

        isLoading = true
        APIService.shared.searchItems(query: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
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

#Preview {
    SearchView()
}
