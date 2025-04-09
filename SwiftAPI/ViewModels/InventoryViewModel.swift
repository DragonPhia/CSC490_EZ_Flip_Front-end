//
//  InventoryViewModel.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/13/25.
//

import Foundation
import SwiftUI

class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var filteredItems: [InventoryItem] = []
    @Published var selectedStatus: String = "all"
    @Published var isLoading: Bool = false
    @Published var selectedImageData: Data? = nil

    init() {
        fetchItems()
    }

    func fetchItems() {
        isLoading = true
        SupabaseService.shared.fetchItems { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.items = items
                    self.applyFilters()
                case .failure(let error):
                    print("❌ Error fetching items: \(error.localizedDescription)")
                }
            }
        }
    }

    func addItem(name: String, purchasePrice: Double?, sellingPrice: Double?, storageLocation: String, notes: String) {
        let newItem = InventoryItem(
            id: UUID().uuidString,
            name: name,
            purchase_price: purchasePrice,
            selling_price: sellingPrice,
            storage_location: storageLocation,
            notes: notes,
            status: "active",
            date_added: ISO8601DateFormatter().string(from: Date()),
            imageURL: nil
        )

        SupabaseService.shared.addItem(newItem) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let item):
                    self.items.append(item)
                    self.applyFilters()
                    print("✅ Item added successfully")
                case .failure(let error):
                    print("❌ Failed to add item: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateItem(_ item: InventoryItem) {
        SupabaseService.shared.updateItem(item) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                        self.items[index] = item
                        self.applyFilters()
                        print("✅ Item updated")
                    }
                case .failure(let error):
                    print("❌ Update failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func deleteItem(_ item: InventoryItem) {
        SupabaseService.shared.deleteItem(id: item.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self.items.removeAll { $0.id == item.id }
                    self.applyFilters()
                case .failure(let error):
                    print("❌ Deletion failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func applyFilters() {
        if selectedStatus == "all" {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.status.lowercased() == selectedStatus.lowercased() }
        }
    }

    // MARK: - Summary Computed Stats
    var totalSold: Int {
        items.filter { $0.status.lowercased() == "sold" }.count
    }

    var totalSoldPurchaseCost: Double {
        items.filter { $0.status.lowercased() == "sold" }
            .compactMap { $0.purchase_price }
            .reduce(0, +)
    }

    var totalSoldValue: Double {
        items.filter { $0.status.lowercased() == "sold" }
            .compactMap { $0.selling_price }
            .reduce(0, +)
    }
}


