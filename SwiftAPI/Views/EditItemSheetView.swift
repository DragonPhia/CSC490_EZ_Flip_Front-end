//
//  EditItemSheetView.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//  Updated: 4/9/25 - Added support for image editing and Supabase upload
//

import SwiftUI
import PhotosUI

struct EditItemSheetView: View {
    var item: InventoryItem
    @Binding var showSheet: Bool
    var onSave: ((InventoryItem) -> Void)

    @EnvironmentObject var viewModel: InventoryViewModel
    @State private var name: String
    @State private var purchasePrice: String
    @State private var sellingPrice: String
    @State private var storageLocation: String
    @State private var notes: String
    @State private var status: String

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

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
                Section(header: Text("Image")) {
                    if let selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else if let urlStr = item.imageURL,
                              let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFit()
                        .frame(height: 200)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .opacity(0.4)
                    }

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Change Image", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }

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
                        var updated = InventoryItem(
                            id: item.id,
                            name: name,
                            purchase_price: Double(purchasePrice),
                            selling_price: Double(sellingPrice),
                            storage_location: storageLocation,
                            notes: notes,
                            status: status,
                            date_added: item.date_added,
                            imageURL: item.imageURL
                        )

                        func finalizeUpdate(with imageURL: String?) {
                            if let imageURL = imageURL {
                                updated.imageURL = imageURL
                            }

                            SupabaseService.shared.updateItem(updated) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        print("✅ Updated item in Supabase with image")
                                        onSave(updated)
                                    case .failure(let error):
                                        print("❌ Failed to update: \(error.localizedDescription)")
                                    }
                                    showSheet = false
                                }
                            }
                        }

                        if let imageData = selectedImageData {
                            SupabaseService.shared.uploadImage(data: imageData, for: item.id) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let url):
                                        finalizeUpdate(with: url.absoluteString)
                                    case .failure(let error):
                                        print("❌ Upload error: \(error.localizedDescription)")
                                        finalizeUpdate(with: nil)
                                    }
                                }
                            }
                        } else {
                            finalizeUpdate(with: nil)
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

