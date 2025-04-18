//
//  SwiftAPIApp.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/13/25.
//

import SwiftUI

@main
struct SwiftAPIApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    init() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            print("Fresh install from Xcode — logging out user")

            // Clear any stored login info
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "userName")
            isLoggedIn = false

            // Mark that app has launched before
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                Dashboard()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                ContentView()
            }
        }
    }
}
