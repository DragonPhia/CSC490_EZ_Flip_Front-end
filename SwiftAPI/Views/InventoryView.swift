//
//  InventoryView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI

struct InventoryView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            Text("Inventory")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search...", text: $searchText)
                    .padding(7)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .frame(height: 50)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    InventoryView()
}
