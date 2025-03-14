//
//  SearchView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/26/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for an item...", text: $viewModel.searchText, onCommit: viewModel.fetchResults)
                            .padding(7)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    
                    NavigationLink(destination: VisualScanView()) {
                        Image(systemName: "camera")
                            .padding(10)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .frame(maxWidth: 400)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
                
                ZStack {
                    Color(.secondarySystemBackground)
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            Color.clear.frame(height: 10)
                            
                            if viewModel.isLoading {
                                ProgressView("Searching...")
                                    .padding()
                            } else if viewModel.results.isEmpty && !viewModel.searchText.isEmpty {
                                Text("No results found.")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.results) { item in
                                    NavigationLink(destination: DetailView(item: item)) {
                                        VStack {
                                            HStack(alignment: .top, spacing: 10) {
                                                
                                                // Check if imageUrl is available and valid
                                                if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                                                    
                                                    AsyncImage(url: url) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView()
                                                                .progressViewStyle(CircularProgressViewStyle())
                                                                .padding(20)
                                                        case .success(let image):
                                                            image.resizable().scaledToFit()
                                                                .frame(width: 120, height: 120)
                                                                .cornerRadius(8)
                                                                .padding(.leading)
                                                        case .failure:
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 120, height: 120)
                                                                .cornerRadius(8)
                                                                .padding(.leading)
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                } else {
                                                    Text("No Image Available")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .padding(.leading)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Text(item.title)
                                                        .font(.headline)
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.primary)
                                                    Text("\(item.price.currency == "USD" ? "$" : item.price.currency) \(item.price.value)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                        }
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, minHeight: 120)
                                    }
                                }
                            }
                        }
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .ignoresSafeArea(.keyboard)
                .navigationTitle("Find Items")
            }
        }
    }
}

#Preview {
    SearchView()
}
