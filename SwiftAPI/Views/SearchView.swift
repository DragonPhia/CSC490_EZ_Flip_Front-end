//
//  SearchView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/26/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search for an item...", text: $viewModel.searchText, onCommit: viewModel.fetchResults)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.leading)

                    Button(action: viewModel.fetchResults) {
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        if viewModel.isLoading {
                            ProgressView("Searching...")
                                .padding()
                        } else if viewModel.results.isEmpty && !viewModel.searchText.isEmpty {
                            Text("No results found.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.results) { item in
                                VStack {
                                    HStack(alignment: .top, spacing: 10) {
                                        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFit()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                            .padding(.leading)
                                        }

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(item.title)
                                                .font(.headline)
                                                .multilineTextAlignment(.leading)
                                            Text("\(item.price.currency) \(item.price.value)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, minHeight: 120)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .clipped()
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("Find Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchView()
}
