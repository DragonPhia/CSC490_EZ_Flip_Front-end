//
//  DetailView.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/9/25.
//

import SwiftUI

struct DetailView: View {
    let item: EbayItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Main Image (First in ScrollView)
                        if let imageUrl = item.image?.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 250, height: 250)
                            .cornerRadius(12)
                        }

                        // Additional Images
                        if let additionalImages = item.additionalImages, !additionalImages.isEmpty {
                            ForEach(additionalImages, id: \.imageUrl) { imageWrapper in
                                if let url = URL(string: imageWrapper.imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 250, height: 250)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Text(item.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.leading)

                Text("\(item.price.currency == "USD" ? "$" : item.price.currency) \(item.price.value)")
                    .font(.title3)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Condition: ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.condition ?? "Condition not specified")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Seller:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.seller.username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Feedback Score:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(item.seller.feedbackPercentage)%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !item.categories.isEmpty {
                    let categoryText = item.categories.prefix(3).map { $0.categoryName }.joined(separator: ", ")
                    HStack {
                        Text("Categories:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(categoryText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Link("View on eBay", destination: URL(string: item.itemWebUrl)!)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Item Details")
    }
}
