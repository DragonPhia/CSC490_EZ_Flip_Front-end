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
    
    private var userId: String? = UserDefaults.standard.string(forKey: "userId")

    init() {
        fetchItems()
    }

    func fetchItems() {
        guard let userId = userId else {
            print("❌ User ID not found in UserDefaults.")
            return
        }
        
        isLoading = true
        SupabaseService.shared.fetchItems(for: userId) { result in  // ✅ Pass userId here
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
        
        guard let userId = userId else {
            print("❌ User ID not found, cannot add item.")
            return
        }
        
        let newItem = InventoryItem(
            id: UUID().uuidString,
            name: name,
            purchase_price: purchasePrice,
            selling_price: sellingPrice,
            storage_location: storageLocation,
            notes: notes,
            status: "active",
            date_added: ISO8601DateFormatter().string(from: Date()),
            imageURL: nil,  // Start with nil and set it later after upload
            user_id: userId
        )

        if let imageData = selectedImageData {
            // Upload the image and get the public URL
            SupabaseService.shared.uploadImage(data: imageData, for: newItem.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageURL):
                        var updatedItem = newItem
                        updatedItem.imageURL = imageURL.absoluteString  // Store the public URL in inventory item
                        self.saveItem(updatedItem)  // Save the item to the database
                    case .failure(let error):
                        print("❌ Image upload failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            self.saveItem(newItem)
        }
    }

    private func saveItem(_ item: InventoryItem) {
        SupabaseService.shared.addItem(item) { result in
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

