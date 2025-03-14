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
                if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                } else {
                    Text("No Image Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(item.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.leading)

                Text("\(item.price.currency == "USD" ? "$" : item.price.currency) \(item.price.value)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Display categories
                if !item.categories.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Categories:")
                            .font(.headline)
                            .padding(.top, 8)
                        ForEach(item.categories, id: \.categoryName) { category in
                            Text(category.categoryName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack {
                    Text("Condition: ")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(item.condition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Link("View on eBay", destination: URL(string: item.itemWebUrl)!)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Item Details")
    }
}


