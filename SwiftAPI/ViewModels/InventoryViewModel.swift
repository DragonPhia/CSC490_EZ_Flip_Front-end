//
//  InventoryViewModel.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//
import Foundation

class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var isLoading: Bool = false
    @Published var selectedStatus: String = "all" // all, active, sold, deadpile

    var filteredItems: [InventoryItem] {
        if selectedStatus == "all" {
            return items
        } else {
            return items.filter { $0.status.lowercased() == selectedStatus }
        }
    }

    // MARK: - Fetch Items
    func fetchItems() {
        isLoading = true
        SupabaseService.shared.fetchItems { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedItems):
                    self.items = fetchedItems
                case .failure(let error):
                    print("❌ Failed to fetch items: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Delete Item
    func deleteItem(_ item: InventoryItem) {
        SupabaseService.shared.deleteItem(id: item.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.items.removeAll { $0.id == item.id }
                case .failure(let error):
                    print("❌ Delete error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Add New Item
    func addItem(
        name: String,
        purchasePrice: Double?,
        sellingPrice: Double?,
        storageLocation: String?,
        notes: String?,
        status: String = "active"
    ) {
        let newItem = InventoryItem(
            id: UUID().uuidString,
            name: name,
            purchase_price: purchasePrice,
            selling_price: sellingPrice,
            storage_location: storageLocation,
            notes: notes,
            status: status,
            date_added: ISO8601DateFormatter().string(from: Date())
        )

        SupabaseService.shared.addItem(newItem) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdItem):
                    self.items.append(createdItem)
                case .failure(let error):
                    print("❌ Failed to add item: \(error.localizedDescription)")
                }
            }
        }
    }
}

