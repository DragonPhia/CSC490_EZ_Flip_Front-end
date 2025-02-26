//
//  Dashboard.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/22/25.
//

import SwiftUI

struct Dashboard: View {

    init() {
        UITabBar.appearance().backgroundColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }

    @State private var selectedTab = 0  // Default tab index

    var body: some View {

        TabView(selection: $selectedTab) {

            InventoryView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Inventory")
                }
                .tag(1)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(0)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("You")
                }
                .tag(2)
        }

    }
}

#Preview {
    Dashboard()
}
