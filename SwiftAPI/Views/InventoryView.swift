//
//  InventoryView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//  Worked on by Emmanuel G on 3/13/25
//  Supabase link 3/25/25
//

import SwiftUI
import UniformTypeIdentifiers

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()

    // Sheet Control
    @State private var showAddSheet = false
    @State private var showDetailSheet = false

    // Add Item Inputs
    @State private var newName = ""
    @State private var newPurchasePrice: String = ""
    @State private var newSellingPrice: String = ""
    @State private var newStorageLocation = ""
    @State private var newNotes = ""

    // Selected Item for Detail View
    @State private var selectedItem: InventoryItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Status Filter Picker
                Picker("Filter", selection: $viewModel.selectedStatus) {
                    Text("All").tag("all")
                    Text("Active").tag("active")
                    Text("Sold").tag("sold")
                    Text("Deadpile").tag("deadpile")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Inventory List
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading inventory...")
                    } else if viewModel.filteredItems.isEmpty {
                        Text("No items found.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.filteredItems) { item in
                                Button {
                                    selectedItem = item
                                    showDetailSheet = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                        if let price = item.selling_price {
                                            Text("Selling: $\(price, specifier: "%.2f")")
                                                .font(.subheadline)
                                        }
                                        Text("Status: \(item.status.capitalized)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Export to CSV") {
                        exportToCSV()
                    }
                }
            }
            .onAppear {
                viewModel.fetchItems()
            }
            .sheet(isPresented: $showAddSheet) {
                addItemSheet
            }
            .sheet(isPresented: $showDetailSheet) {
                if let item = selectedItem {
                    InventoryItemDetailView(item: item)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    // MARK: - Delete
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = viewModel.filteredItems[index]
            viewModel.deleteItem(item)
        }
    }

    // MARK: - Add Item Sheet
    var addItemSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $newName)
                    TextField("Purchase Price", text: $newPurchasePrice)
                        .keyboardType(.decimalPad)
                    TextField("Selling Price", text: $newSellingPrice)
                        .keyboardType(.decimalPad)
                    TextField("Storage Location", text: $newStorageLocation)
                    TextField("Notes", text: $newNotes)
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let purchase = Double(newPurchasePrice)
                        let selling = Double(newSellingPrice)
                        viewModel.addItem(
                            name: newName,
                            purchasePrice: purchase,
                            sellingPrice: selling,
                            storageLocation: newStorageLocation,
                            notes: newNotes
                        )
                        showAddSheet = false
                        clearAddItemFields()
                    }
                    .disabled(newName.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddSheet = false
                        clearAddItemFields()
                    }
                }
            }
        }
    }

    // MARK: - Reset Fields
    func clearAddItemFields() {
        newName = ""
        newPurchasePrice = ""
        newSellingPrice = ""
        newStorageLocation = ""
        newNotes = ""
    }

    // MARK: - Export CSV
    func exportToCSV() {
        let fileName = "Inventory_Export.csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var csvText = "Name,Purchase Price,Selling Price,Storage Location,Notes,Status,Date Added\n"

        for item in viewModel.items {
            let row = [
                item.name,
                item.purchase_price.map { String($0) } ?? "",
                item.selling_price.map { String($0) } ?? "",
                item.storage_location ?? "",
                item.notes ?? "",
                item.status.capitalized,
                item.date_added
            ]
            .map { $0.replacingOccurrences(of: ",", with: " ") } // clean commas
            .joined(separator: ",")

            csvText += row + "\n"
        }

        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)

            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }
        } catch {
            print("❌ Failed to write CSV: \(error.localizedDescription)")
        }
    }
}


#Preview {
    InventoryView()
}
