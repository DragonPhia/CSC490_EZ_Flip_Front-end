//
//  ProfileView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/25/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var username: String = "JohnDoe"
    @State private var email: String = "johndoe@example.com"
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
                            Text(username).font(.headline)
                            Text(email).font(.subheadline).foregroundColor(.gray)
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
                
                Section(header: Text("eBay Account")) {
                    Button("Connect eBay Account") {
                        // eBay account connection
                    }
                    .foregroundColor(.blue)
                }
                
                Section {
                    Button("Save Changes") {
                        // save action
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light) // Apply dark mode setting
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
