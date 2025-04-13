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

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                Dashboard()
            } else {
                ContentView()
            }
        }
    }
}
