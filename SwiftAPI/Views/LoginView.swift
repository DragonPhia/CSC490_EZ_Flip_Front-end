//
//  LoginView.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/31/25.
//

import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @Binding var user: User?
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            
            // Background image
            Image("EZ_Flip-removebg-preview 1")
                .resizable()
                .scaledToFill()
                .frame(width: 380, height: 350)
        
            ZStack {
                
                VStack(spacing: 16) {
                    Button {
                        handleSignupButton()
                    } label: {
                        Text("Sign in with Google")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 80)
                }
                .padding()
            }
        }
        .padding()
    }
    
    // Handle Google Sign-in
    func handleSignupButton() {
        print("Sign in with Google clicked")
        
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard let result else {
                    print("Google Sign-In failed: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                // Get the user's name and email
                let name = result.user.profile?.name ?? "Unknown"
                let email = result.user.profile?.email ?? "No Email"
                self.user = User(name: name, email: email)
                
                print("Name: \(name)")
                print("Email: \(email)")
                
                // Access the access token and refresh token directly (no optional chaining needed)
                let accessToken = result.user.accessToken.tokenString
                print("Access Token: \(accessToken)")
                
                // Use the access token to make API requests
                // For example, interact with Google Sheets API here

                let refreshToken = result.user.refreshToken.tokenString
                print("Refresh Token: \(refreshToken)")
                // Store the refresh token for future use
            }
        }
    }
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as?
            UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    
    if let presented = vc.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    return vc
}
