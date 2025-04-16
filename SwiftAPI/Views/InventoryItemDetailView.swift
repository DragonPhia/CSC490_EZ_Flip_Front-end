//
//  InventoryItemDetailView.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/13/25.
//

import SwiftUI

struct InventoryItemDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: InventoryViewModel

    let item: InventoryItem
    @State private var showEditSheet = false
    @State private var currentItem: InventoryItem

    init(item: InventoryItem) {
        self.item = item
        _currentItem = State(initialValue: item)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    Text("Name: \(currentItem.name)")
                    if let price = currentItem.selling_price {
                        Text("Selling Price: $\(price, specifier: "%.2f")")
                    }
                    if let purchase = currentItem.purchase_price {
                        Text("Purchase Price: $\(purchase, specifier: "%.2f")")
                    }
                    if let location = currentItem.storage_location {
                        Text("Storage: \(location)")
                    }
                    Text("Status: \(currentItem.status.capitalized)")
                    Text("Date Added: \(currentItem.date_added)")
                }

                Section(header: Text("Notes")) {
                    Text(currentItem.notes ?? "None")
                }

                Section(header: Text("Image")) {
                    if let imageURL = currentItem.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .cornerRadius(8)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .opacity(0.4)
                    }
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Item Details")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("Edit") {
                            showEditSheet = true
                        }
                        .font(.body)
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditItemSheetView(item: currentItem, showSheet: $showEditSheet) { updated in
                    currentItem = updated
                    viewModel.fetchItems()
                }
                .environmentObject(viewModel)
            }
        }
    }
}
