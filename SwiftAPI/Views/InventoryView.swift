//
//  InventoryView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//  Worked on by Emmanuel G on 3/13/25
//

import SwiftUI

struct InventoryView: View {
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .mostRecent
    @State private var selectedItems: Set<UUID> = []
    @State private var isEditing: Bool = false
    @State private var showAddItemSheet: Bool = false
    
    private func toggleItemStatus(_ item: InventoryItem) {
        if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
            inventoryItems[index].status = (inventoryItems[index].status == "Sold") ? "Active" : "Sold"
        }
    }

    enum SortOption: String, CaseIterable {
        case highToLow = "Price: High to Low"
        case lowToHigh = "Price: Low to High"
        case mostRecent = "Most Recent"
        case earliest = "Earliest"
        case sold = "Sold"
        case notSold = "Not Sold"
    }

    struct InventoryItem: Identifiable {
        let id = UUID()
        var name: String
        var price: Double
        var status: String
        var imageName: String?
    }

    @State private var inventoryItems = [
        InventoryItem(name: "Nike Air Force 1", price: 100, status: "Active", imageName: "shoe"),
        InventoryItem(name: "Jorts (Denim Shorts)", price: 25, status: "Sold", imageName: "pants"),
        InventoryItem(name: "Vintage Jacket", price: 45, status: "Active", imageName: "jacket"),
        InventoryItem(name: "Gaming Mouse", price: 30, status: "Sold", imageName: "mouse")
    ]

    var sortedFilteredItems: [InventoryItem] {
        var items = inventoryItems

        // Apply search filtering
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.status.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply sorting
        switch sortOption {
            case .highToLow:
                items.sort { $0.price > $1.price }
            case .lowToHigh:
                items.sort { $0.price < $1.price }
            case .mostRecent:
                break // Placeholder for real sorting
            case .earliest:
                break // Placeholder for real sorting
            case .sold:
                items = items.filter { $0.status == "Sold" }
            case .notSold:
                items = items.filter { $0.status != "Sold" }
        }
        return items
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search...", text: $searchText)
                        .padding(7)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Sorting Options
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                // Export Data Button (Placeholder)
                Button(action: {
                    print("Export Data button tapped - Feature to be implemented.")
                    // Placeholder for future CSV export functionality
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Data")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Inventory List (Default View)
                List {
                    ForEach(sortedFilteredItems) { item in
                        InventoryListItem(item: item, isSelected: selectedItems.contains(item.id))
                            .onTapGesture {
                                if isEditing {
                                    if selectedItems.contains(item.id) {
                                        selectedItems.remove(item.id)
                                    } else {
                                        selectedItems.insert(item.id)
                                    }
                                } else {
                                    print("Open Detail View for \(item.name)")
                                }
                            }
                            .swipeActions(edge: .leading) { // Swipe right to update status
                                Button {
                                    toggleItemStatus(item)
                                } label: {
                                    Label(item.status == "Sold" ? "Update to Active" : "Update to Sold",
                                          systemImage: item.status == "Sold" ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                                }
                                .tint(item.status == "Sold" ? .blue : .red) // Red for Sold, Blue for Active
                            }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let itemToDelete = sortedFilteredItems[index]
                            if let originalIndex = inventoryItems.firstIndex(where: { $0.id == itemToDelete.id }) {
                                inventoryItems.remove(at: originalIndex)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Multi-Select Toolbar
                if isEditing {
                    HStack {
                        Button("Mark as Sold") {
                            for id in selectedItems {
                                if let index = inventoryItems.firstIndex(where: { $0.id == id }) {
                                    inventoryItems[index].status = "Sold"
                                }
                            }
                            selectedItems.removeAll()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Delete") {
                            inventoryItems.removeAll { selectedItems.contains($0.id) }
                            selectedItems.removeAll()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }

                // Floating Add Button
                Button(action: { showAddItemSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
                .sheet(isPresented: $showAddItemSheet) {
                    AddNewItemView(inventoryItems: $inventoryItems)
                }
            }
            .navigationTitle("Inventory")
            .navigationBarItems(trailing: EditButton().onTapGesture {
                isEditing.toggle()
                selectedItems.removeAll()
            })
        }
    }
}

// Inventory List Item View
struct InventoryListItem: View {
    let item: InventoryView.InventoryItem
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: item.imageName ?? "cart.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(5)

            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text("Bought for: $\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(item.status)
                .foregroundColor(item.status == "Sold" ? .red : .green)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// Add New Item View
struct AddNewItemView: View {
    @Binding var inventoryItems: [InventoryView.InventoryItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var status: String = "Active"

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                Picker("Status", selection: $status) {
                    Text("Active").tag("Active")
                    Text("Sold").tag("Sold")
                }
            }
            .navigationBarItems(trailing: Button("Save") {
                if let priceValue = Double(price) {
                    inventoryItems.append(InventoryView.InventoryItem(name: name, price: priceValue, status: status))
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}

#Preview {
    InventoryView()
}

