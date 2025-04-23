//
//  ContentView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/13/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginMessage: String = ""
    @State private var isLoginSuccessful: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Image("EZ_Flip-removebg-preview 1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 125, maxHeight: 400) // sets a min size
                    .padding(.top, 40)

                // Login Message
                if !loginMessage.isEmpty {
                    Text(loginMessage)
                        .font(.subheadline)
                        .foregroundColor(isLoginSuccessful ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

                    Button(action: {
                        loginUser()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }

                    HStack {
                        Spacer()

                        NavigationLink(destination: RegisterView()) {
                            Text("Register")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onTapGesture {
                hideKeyboard()
            }
        }
        .preferredColorScheme(.light)
    }

    func loginUser() {
        guard let url = URL(string: "https://ezflip.onrender.com/auth/login") else { return }

        let body: [String: Any] = [
            "email": email,
            "password": password,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    loginMessage = "Login error: \(error.localizedDescription)"
                    isLoginSuccessful = false
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    loginMessage = "Invalid server response."
                    isLoginSuccessful = false
                    return
                }

                guard let data = data else {
                    loginMessage = "No data received."
                    isLoginSuccessful = false
                    return
                }

                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let session = json["session"] as? [String: Any],
                           let token = session["access_token"] as? String {

                            if let user = json["user"] as? [String: Any],
                               let identities = user["identities"] as? [[String: Any]],
                               let identityData = identities.first?["identity_data"] as? [String: Any] {

                                if let email = identityData["email"] as? String {
                                    UserDefaults.standard.set(email, forKey: "userEmail")
                                }

                                if let displayName = identityData["display_name"] as? String {
                                    UserDefaults.standard.set(displayName, forKey: "userName")
                                }

                                if let userId = user["id"] as? String {
                                    UserDefaults.standard.set(userId, forKey: "userId")
                                    print("USER ID!!!!!!: \(userId)")
                                }
                            }

                            isLoggedIn = true
                            loginMessage = "Login successful!"
                            isLoginSuccessful = true
                        } else {
                            loginMessage = "Login failed: Invalid credentials."
                            isLoginSuccessful = false
                        }
                    } else {
                        loginMessage = "Invalid response format."
                        isLoginSuccessful = false
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        loginMessage = "Login failed: \(message)"
                    } else {
                        loginMessage = "Login failed with status: \(httpResponse.statusCode)"
                    }
                    isLoginSuccessful = false
                }
            }
        }.resume()
    }
}

