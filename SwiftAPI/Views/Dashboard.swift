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
            VisualScanView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Scan")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

            InventoryView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Inventory")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("You")
                }
                .tag(3)
        }

    }
}

#Preview {
    Dashboard()
}
