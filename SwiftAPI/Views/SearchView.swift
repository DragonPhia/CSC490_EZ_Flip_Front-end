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
    @State private var selectedImage: UIImage? = nil // Added for image preview
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.blue, lineWidth: 2) // Border to signify selection
                            )
                    }
                    // Search Field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for an item...", text: $viewModel.searchText, onCommit: {
                            viewModel.fetchResults()
                            selectedImage = nil // Reset selected image when searching
                        })
                            .padding(7)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    // Camera Button
                    NavigationLink(destination: VisualScanView(onImageSelected: { image in
                        viewModel.searchText = ""
                        selectedImage = image
                        viewModel.searchByImage(image: image)
                    })) {
                        Image(systemName: "camera")
                            .padding(10)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .frame(maxWidth: 400)
                .padding(.horizontal)
                // Market Insights
                VStack(alignment: .leading, spacing: 5) {
                    Text("Market Insights")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Avg. Listed Price: $\(viewModel.averageListedPrice, specifier: "%.2f")")
                                .font(.footnote)
                                .bold()
                            Text("Total Active Listings: \(viewModel.totalActiveListings)")
                                .font(.footnote)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Highest Price: $\(viewModel.highestPrice, specifier: "%.2f")")
                                .font(.footnote)
                                .bold()
                            Text("Lowest Price: $\(viewModel.lowestPrice, specifier: "%.2f")")
                                .font(.footnote)
                                .bold()
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.horizontal)
                // Item List
                ZStack {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            Color.clear.frame(height: 1)
                            if viewModel.isLoading {
                                ProgressView("Searching...")
                                    .padding()
                            } else if viewModel.results.isEmpty && !viewModel.searchText.isEmpty {
                                Text("No results found.")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                // Ebay item
                                ForEach(viewModel.results.prefix(viewModel.loadedItemCount)) { item in
                                    NavigationLink(destination: DetailView(item: item)) {
                                        VStack {
                                            HStack(alignment: .top, spacing: 10) {
                                                if let imageUrl = item.image?.imageUrl,
                                                   let url = URL(string: imageUrl) {
                                                    AsyncImage(url: url) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView()
                                                                .progressViewStyle(CircularProgressViewStyle())
                                                                .padding(20)
                                                        case .success(let image):
                                                            image.resizable()
                                                                .scaledToFit()
                                                                .frame(width: 110, height: 110)
                                                                .cornerRadius(10)
                                                                .padding(.leading)
                                                        case .failure:
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 110, height: 110)
                                                                .cornerRadius(10)
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
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(item.title)
                                                        .font(.headline)
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.primary)
                                                    Text("\(item.price.currency == "USD" ? "$" : item.price.currency) \(item.price.value)")
                                                        .font(.subheadline)
                                                        .foregroundColor(Color(.systemGreen))
                                                }
                                                Spacer()
                                            }
                                            .padding(10)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 110)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                        .padding(.horizontal)
                                        .onAppear {
                                            viewModel.loadMoreItemsIfNeeded(item: item)
                                        }
                                    }
                                }
                                if viewModel.loadedItemCount < viewModel.results.count {
                                    ProgressView("Loading more items...")
                                        .padding()
                                        .onAppear {
                                            viewModel.loadMoreItemsIfNeeded(item: viewModel.results.last!)
                                        }
                                }
                            }
                            Color.clear.frame(height: 2)
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
