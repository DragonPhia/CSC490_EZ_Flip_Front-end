//
//  InventoryViewModel.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//

import Foundation
import SwiftUI

class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    @Published var isLoading: Bool = false
    @Published var selectedStatus: String = "all" // all, active, sold, deadpile
    @Published var selectedImageData: Data? = nil

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
        let newItemID = UUID().uuidString
        let newItem = InventoryItem(
            id: newItemID,
            name: name,
            purchase_price: purchasePrice,
            selling_price: sellingPrice,
            storage_location: storageLocation,
            notes: notes,
            status: status,
            date_added: ISO8601DateFormatter().string(from: Date())
        )

        func finalizeAdd(with imageURL: String?) {
            var finalItem = newItem
            finalItem.imageURL = imageURL
            SupabaseService.shared.addItem(finalItem) { result in
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

        if let imageData = selectedImageData {
            SupabaseService.shared.uploadImage(data: imageData, for: newItemID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        finalizeAdd(with: url.absoluteString)
                    case .failure(let error):
                        print("❌ Image upload failed: \(error.localizedDescription)")
                        finalizeAdd(with: nil)
                    }
                }
            }
        } else {
            finalizeAdd(with: nil)
        }
    }

    // MARK: - Update Existing Item
    func updateItem(_ updatedItem: InventoryItem, withImageData imageData: Data?, completion: @escaping (Bool) -> Void) {
        if let imageData = imageData {
            SupabaseService.shared.uploadImage(data: imageData, for: updatedItem.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        var updated = updatedItem
                        updated.imageURL = url.absoluteString
                        self.pushUpdate(updated, completion: completion)
                    case .failure(let error):
                        print("❌ Failed to upload new image: \(error.localizedDescription)")
                        self.pushUpdate(updatedItem, completion: completion)
                    }
                }
            }
        } else {
            pushUpdate(updatedItem, completion: completion)
        }
    }

    private func pushUpdate(_ item: InventoryItem, completion: @escaping (Bool) -> Void) {
        SupabaseService.shared.updateItem(item) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Updated item in Supabase with image")
                    if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                        self.items[index] = item
                    }
                    completion(true)
                case .failure(let error):
                    print("❌ Update error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    // MARK: - Clear Image Field
    func clearAddItemFields() {
        selectedImageData = nil
    }
}

