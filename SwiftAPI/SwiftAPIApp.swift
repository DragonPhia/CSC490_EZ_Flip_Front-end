//
//  SwiftAPIApp.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/13/25.
//

import SwiftUI
import GoogleSignIn

@main
struct SwiftAPIApp: App {
    @State var user: User?
    
    var body: some Scene {
        WindowGroup {
            Dashboard(user: $user)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn() {
                        user, error in
                        if let user = user {
                            self.user = .init(
                                name: user.profile?.name ?? "Unknown",
                                email: user.profile?.email ?? "No Email"
                            )
                        }
                    }
                }
        }
    }
}

struct User {
    var name: String
    var email: String
}
