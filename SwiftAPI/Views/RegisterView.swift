//
//  RegisterView.swift
//  SwiftAPI
//
//  Created by Dragon P on 4/12/25.
//

import Foundation
import SwiftUI

public struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var displayName: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)

                    VStack(spacing: 16) {
                        Group {
                            CustomTextField("Email", text: $email, isSecure: false)
                            CustomTextField("Password", text: $password, isSecure: true)
                            CustomTextField("Username", text: $username, isSecure: false)
                            CustomTextField("Display Name", text: $displayName, isSecure: false)
                        }
                        .padding(.horizontal)
                    }

                    Button(action: {
                        // Validate input fields
                        if email.isEmpty || password.isEmpty || username.isEmpty || displayName.isEmpty {
                            alertMessage = "All fields are required!"
                            showAlert = true
                        } else {
                            registerUser()
                            hideKeyboard()
                        }
                    }) {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(.keyboard) // this is key
            .onTapGesture {
                hideKeyboard()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    func registerUser() {
        guard let url = URL(string: "https://ezflip.onrender.com/auth/register") else { return }

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "username": username,
            "display_name": displayName,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                print("Register Response:", json ?? "")

                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } else if let error = error {
                print("Registration Error:", error.localizedDescription)
            }
        }.resume()
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool

    init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}
