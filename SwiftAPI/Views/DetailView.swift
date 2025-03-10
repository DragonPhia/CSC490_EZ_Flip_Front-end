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
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
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
                
                if let category = item.category {
                    Text("Category: \(category)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Link("View on eBay", destination: URL(string: item.itemURL)!)
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


