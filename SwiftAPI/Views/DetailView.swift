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
                if let imageUrl = item.image.imageUrl, let url = URL(string: imageUrl) {
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
                
                HStack {
                    Text("Condition: ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.condition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Displaying Categories
                if !item.categories.isEmpty {
                    Text("Categories:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(item.categories, id: \.categoryName) { category in
                        Text(category.categoryName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 1)
                    }
                }

                // Updated Link to eBay
                Link("View on eBay", destination: URL(string: item.itemWebUrl)!)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                Spacer()
            }
            .padding()
            .frame(maxHeight: 600, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Item Details")
    }
}
