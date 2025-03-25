//
//  InventoryItemDetailView.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//
import SwiftUI

struct InventoryItemDetailView: View {
    @EnvironmentObject var viewModel: InventoryViewModel
    var item: InventoryItem

    @State private var showEditSheet = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    Text(item.name)
                }

                Section(header: Text("Purchase Price")) {
                    Text(item.purchase_price != nil ? "$\(item.purchase_price!, specifier: "%.2f")" : "N/A")
                }

                Section(header: Text("Selling Price")) {
                    Text(item.selling_price != nil ? "$\(item.selling_price!, specifier: "%.2f")" : "N/A")
                }

                Section(header: Text("Storage Location")) {
                    Text(item.storage_location ?? "N/A")
                }

                Section(header: Text("Notes")) {
                    Text(item.notes ?? "None")
                }

                Section(header: Text("Status")) {
                    Text(item.status.capitalized)
                }

                Section(header: Text("Date Added")) {
                    Text(item.date_added)
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditItemSheetView(item: item, showSheet: $showEditSheet) { updatedItem in
                    if let index = viewModel.items.firstIndex(where: { $0.id == updatedItem.id }) {
                        viewModel.items[index] = updatedItem
                    }
                }
            }
        }
    }
}




