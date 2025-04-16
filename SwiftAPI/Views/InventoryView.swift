//
//  InventoryView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//  Worked on by Emmanuel G on 3/13/25
//  Supabase integration updated 4/9/25
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import Combine // for searchview

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    
    // For external trigger from other views
    static var sharedAddSheetTrigger = PassthroughSubject<UIImage, Never>() // for searchview
    // New Combine storage
    @State private var cancellables = Set<AnyCancellable>() // for searchview
    
    // Sheet Control
    @State private var showAddSheet = false
    @State private var showDetailSheet = false
    
    // Add Item Inputs
    @State private var newName = ""
    @State private var newPurchasePrice: String = ""
    @State private var newSellingPrice: String = ""
    @State private var newStorageLocation = ""
    @State private var newNotes = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    // Selected Item for Detail View
    @State private var selectedItem: InventoryItem? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SummaryStatsView(viewModel: viewModel)
                    .padding(.bottom)
                
                Picker("Filter", selection: $viewModel.selectedStatus) {
                    Text("All").tag("all")
                    Text("Active").tag("active")
                    Text("Sold").tag("sold")
                    Text("Deadpile").tag("deadpile")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
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
                                NavigationLink(destination: InventoryItemDetailView(item: item).environmentObject(viewModel)) {
                                    HStack(alignment: .top, spacing: 12) {
                                        if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 60, height: 60)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 60, height: 60)
                                                        .clipped()
                                                        .cornerRadius(6)
                                                case .failure:
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .foregroundColor(.red)
                                                        .opacity(0.7)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.gray)
                                                .opacity(0.3)
                                        }
                                        
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
                                    }
                                    .padding(.vertical, 5)
                                    .contentShape(Rectangle())
                                }
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
                    Button("Export Sold Items to CSV") {
                        exportToCSV()
                    }
                }
            }
            .onAppear {
                viewModel.fetchItems()
                
                // for search view
                InventoryView.sharedAddSheetTrigger
                    .sink { image in
                        viewModel.selectedImageData = image.jpegData(compressionQuality: 0.8)
                        showAddSheet = true
                    }
                    .store(in: &cancellables)
            }
            .onChange(of: viewModel.selectedStatus) { _ in
                viewModel.applyFilters()
            }
            
            .sheet(isPresented: $showAddSheet) {
                addItemSheet
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
                
                Section(header: Text("Image")) {
                    if let data = viewModel.selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.vertical, 4)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                            .opacity(0.4)
                            .padding(.vertical, 4)
                    }
                    
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Select Image", systemImage: "photo")
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                viewModel.selectedImageData = data
                            }
                        }
                    }
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
        viewModel.selectedImageData = nil
    }
    
    // MARK: - Export CSV (Only Sold Items with Business Stats)
    func exportToCSV() {
        let fileName = "Sold_Inventory_Export.csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var csvText = "Name,Purchase Price,Selling Price,Storage Location,Notes,Date Added\n"
        
        let soldItems = viewModel.items.filter { $0.status.lowercased() == "sold" }
        
        var totalCost: Double = 0
        var totalRevenue: Double = 0
        
        for item in soldItems {
            let purchasePrice = item.purchase_price ?? 0
            let sellingPrice = item.selling_price ?? 0
            
            totalCost += purchasePrice
            totalRevenue += sellingPrice
            
            let row = [
                item.name,
                "\(purchasePrice)",
                "\(sellingPrice)",
                item.storage_location ?? "",
                item.notes?.replacingOccurrences(of: ",", with: " ") ?? "",
                item.date_added
            ].joined(separator: ",")
            
            csvText += row + "\n"
        }
        
        let profitOrLoss = totalRevenue - totalCost
        let profitLossStatus = profitOrLoss >= 0 ? "Profit" : "Loss"
        
        csvText += "\nBusiness Stats,,,\n"
        csvText += "Total Cost,$\(String(format: "%.2f", totalCost))\n"
        csvText += "Total Revenue,$\(String(format: "%.2f", totalRevenue))\n"
        csvText += "\(profitLossStatus),$\(String(format: "%.2f", abs(profitOrLoss)))\n"
        
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
