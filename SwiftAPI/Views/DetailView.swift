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
                // Main Image (Centered)
                if let imageUrl = item.image?.imageUrl, let url = URL(string: imageUrl) {
                    HStack {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 250) // Fixed height for main image
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity) // Center the main image
                } else {
                    Text("No Image Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity) // Center the text as well
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

                // Displaying first 3 categories
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

                // Link to eBay
                Link("View on eBay", destination: URL(string: item.itemWebUrl)!)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                // Displaying additional images if available
                if let additionalImages = item.additionalImages, !additionalImages.isEmpty {
                    Text("Additional Images:")
                        .font(.headline)
                        .padding(.top, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Safely unwrap and iterate through additionalImages
                            ForEach(additionalImages, id: \.imageUrl) { imageWrapper in
                                if let url = URL(string: imageWrapper.imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 120, height: 120) // Smaller size for additional images
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                } else {
                    Text("No additional images available.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) // Removed maxHeight constraint
        }
        .navigationTitle("Item Details")
    }
}
