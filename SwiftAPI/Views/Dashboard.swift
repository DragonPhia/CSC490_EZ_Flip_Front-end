//
//  Dashboard.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/22/25.
//

import SwiftUI

struct Dashboard: View {

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

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
