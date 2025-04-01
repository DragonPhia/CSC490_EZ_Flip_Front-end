//
//  Dashboard.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/22/25.
//

import SwiftUI
import GoogleSignIn


struct Dashboard: View {
    @Binding var user: User?

        init(user: Binding<User?>) {  // ✅ Explicit initializer
            self._user = user  // ✅ Assign Binding

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
                .tag(1)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(0)

            if let user = user {
                ProfileView(user: self.$user)  // ✅ Pass user binding
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Hi there, \(user.name)")
                    }
                    .tag(2)
            } else {
                LoginView(user: self.$user)  // ✅ Pass user binding
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(2)
            }
            
        }

    }
}

#Preview {
    Dashboard(user: .constant(nil)) 
}
