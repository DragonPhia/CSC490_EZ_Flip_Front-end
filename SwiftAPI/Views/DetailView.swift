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
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    TabView {
                        // Main Image (First in Carousel)
                        if let imageUrl = item.image?.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit() // Use scaledToFit to prevent zooming
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 250)
                                    .cornerRadius(15)
                                    .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                                    .shadow(radius: 10)
                                    .animation(.easeInOut(duration: 0.3), value: item.image?.imageUrl)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        // Additional Images
                        if let additionalImages = item.additionalImages, !additionalImages.isEmpty {
                            ForEach(additionalImages, id: \.imageUrl) { imageWrapper in
                                if let url = URL(string: imageWrapper.imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit() // Use scaledToFit to prevent zooming
                                            .frame(width: UIScreen.main.bounds.width - 40, height: 250)
                                            .cornerRadius(15)
                                            .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                                            .shadow(radius: 10)
                                            .animation(.easeInOut(duration: 0.3), value: imageWrapper.imageUrl)
                                    } placeholder: {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 250) // Keep consistent with the frame height
                }
                .padding(.horizontal, 10)
                // Title
                Text(item.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
                // Price - Green Color
                Text("\(item.price.currency == "USD" ? "$" : item.price.currency) \(item.price.value)")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(.bottom, 4)
                // Separator Line
                Divider()
                    .padding(.vertical, 4)
                // Condition
                HStack {
                    Label("Condition:", systemImage: "tag.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.condition ?? "Condition not specified")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
                // Seller
                HStack {
                    Label("Seller:", systemImage: "person.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(item.seller.username)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
                // Feedback Score
                HStack {
                    Label("Feedback Score:", systemImage: "star.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(item.seller.feedbackPercentage)%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
                // Separator Line
                Divider()
                    .padding(.vertical, 4)
                // Categories
                if !item.categories.isEmpty {
                    let categoryText = item.categories.prefix(3).map { $0.categoryName }.joined(separator: ", ")
                    HStack {
                        Label("Categories:", systemImage: "folder.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(categoryText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 4)
                }
                // Link to eBay
                Link("View on eBay", destination: URL(string: item.itemWebUrl)!)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.top, 12)
                Spacer()
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Item Details")
    }
}
