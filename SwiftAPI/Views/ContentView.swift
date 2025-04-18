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

    var body: some View {
        NavigationView {
            VStack {
                Image("EZ_Flip-removebg-preview 1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 380, height: 350)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .background(Color.white.opacity(0.2))
                        .frame(width: 350, height: 300)

                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .padding()
                            .frame(height: 45)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.horizontal)

                        SecureField("Password", text: $password)
                            .padding()
                            .frame(height: 45)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.horizontal)

                        Button(action: {
                            loginUser()
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        HStack {
                            Button(action: {
                                // Handle forgot password
                            }) {
                                Text("Forgot password?")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            NavigationLink(destination: RegisterView()) {
                                Text("Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 100)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)

                        if !loginMessage.isEmpty {
                            Text(loginMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .preferredColorScheme(.light) // Force light mode here
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
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    loginMessage = "Invalid server response."
                    return
                }

                guard let data = data else {
                    loginMessage = "No data received."
                    return
                }

                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        //print("Login response:", json)

                        if let session = json["session"] as? [String: Any],
                           let token = session["access_token"] as? String {
                            //print("Token received: \(token)")

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
                                    UserDefaults.standard.set(userId, forKey: "userId") // <- Store user ID
                                    print("USER ID!!!!!!: \(userId)")
                                }
                            }

                            isLoggedIn = true
                            loginMessage = ""
                        } else {
                            loginMessage = "Login failed: Invalid credentials."
                        }
                    } else {
                        loginMessage = "Invalid response format."
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        loginMessage = "Login failed: \(message)"
                    } else {
                        loginMessage = "Login failed with status: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}
