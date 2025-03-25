//
//  EditItemSheetView.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//
import SwiftUI

struct EditItemSheetView: View {
    var item: InventoryItem
    @Binding var showSheet: Bool
    var onSave: ((InventoryItem) -> Void)

    @State private var name: String
    @State private var purchasePrice: String
    @State private var sellingPrice: String
    @State private var storageLocation: String
    @State private var notes: String
    @State private var status: String

    init(item: InventoryItem, showSheet: Binding<Bool>, onSave: @escaping (InventoryItem) -> Void) {
        self.item = item
        self._showSheet = showSheet
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _purchasePrice = State(initialValue: item.purchase_price.map { "\($0)" } ?? "")
        _sellingPrice = State(initialValue: item.selling_price.map { "\($0)" } ?? "")
        _storageLocation = State(initialValue: item.storage_location ?? "")
        _notes = State(initialValue: item.notes ?? "")
        _status = State(initialValue: item.status)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Info")) {
                    TextField("Name", text: $name)
                    TextField("Purchase Price", text: $purchasePrice)
                        .keyboardType(.decimalPad)
                    TextField("Selling Price", text: $sellingPrice)
                        .keyboardType(.decimalPad)
                    TextField("Storage Location", text: $storageLocation)
                    TextField("Notes", text: $notes)

                    Picker("Status", selection: $status) {
                        Text("Active").tag("active")
                        Text("Sold").tag("sold")
                        Text("Deadpile").tag("deadpile")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = InventoryItem(
                            id: item.id,
                            name: name,
                            purchase_price: Double(purchasePrice),
                            selling_price: Double(sellingPrice),
                            storage_location: storageLocation,
                            notes: notes,
                            status: status,
                            date_added: item.date_added
                        )

                        SupabaseService.shared.updateItem(updated) { result in
                            switch result {
                            case .success:
                                print("✅ Updated item in Supabase")
                                onSave(updated) // 🔁 Update local copy
                            case .failure(let error):
                                print("❌ Failed to update: \(error.localizedDescription)")
                            }

                            showSheet = false
                        }
                    }
                    .disabled(name.isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
            }
        }
    }
}


