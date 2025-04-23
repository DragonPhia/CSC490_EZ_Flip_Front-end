//
//  ProfileView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "userName") ?? "JohnDoe"
    @State private var email: String = UserDefaults.standard.string(forKey: "userEmail") ?? "johndoe@example.com"
    @State private var preferredCurrency: String = "USD"
    @State private var notificationsEnabled: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true

    let currencies = ["USD", "EUR", "GBP", "JPY", "AUD"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text(username).font(.headline)
                            Text(email).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text("User Settings")) {

                    Toggle("Dark Mode", isOn: $isDarkMode)
                }

                Section {
                    Button("Log Out") {
                        isLoggedIn = false
                        UserDefaults.standard.removeObject(forKey: "userEmail")
                        UserDefaults.standard.removeObject(forKey: "userName")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}


