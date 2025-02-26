//
//  SearchView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/26/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearchBarVisible = false  // Animation state
    @State private var scaleEffect: CGFloat = 0.5 // Start slightly smaller
    
    var body: some View {
        NavigationStack {
            VStack {
                if isSearchBarVisible {
                    TextField("Search for an item...", text: $searchText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(40)
                        .padding(.horizontal)
                        .scaleEffect(scaleEffect) // Apply bounce effect
                        .transition(.opacity) // Smooth fade-in transition
                        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: isSearchBarVisible)
                }

                Text("Searching for: \(searchText)")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Find Item")
        }
        .onAppear {
            isSearchBarVisible = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                scaleEffect = 1.0  // Bounce effect
            }
        }
        .onDisappear {
            isSearchBarVisible = false
            scaleEffect = 0.8
        }
        
    }

}


#Preview {
    SearchView()
}
