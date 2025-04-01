//
//  ProfileView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    @Binding var user: User?  // ✅ Bind user data

    @State private var preferredCurrency: String = "USD"
    @State private var notificationsEnabled: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

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
                            Text(user?.name ?? "Unknown") // ✅ Show user name
                                .font(.headline)
                            Text(user?.email ?? "No email available") // ✅ Show user email
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Section(header: Text("User Settings")) {
                    Picker("Preferred Currency", selection: $preferredCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }

                    Toggle("Dark Mode", isOn: $isDarkMode)
                }

                Section {
                    Button("Save Changes") {
                        // Save action
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                if let user {
                    Button(action: {
                        GIDSignIn.sharedInstance.signOut()
                        self.user = nil
                    }) {
                        Text("Log out")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)  // Use a different color (red for example) for log-out
                            .cornerRadius(10)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light) // Apply dark mode setting
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView(user: .constant(User(name: "John Doe", email: "johndoe@example.com")))
}
