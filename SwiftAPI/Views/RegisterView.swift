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
    
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
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
                        .frame(width: 350, height: 420)

                    VStack(spacing: 16) {
                        Group {
                            TextField("Email", text: $email)
                            SecureField("Password", text: $password)
                            TextField("Username", text: $username)
                            TextField("Display Name", text: $displayName)
                        }
                        .padding()
                        .frame(height: 45)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)

                        Button(action: {
                            registerUser()
                        }) {
                            Text("Register")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }

    func registerUser() {
        guard let url = URL(string: "https://ezflip.onrender.com/auth/register")
        else { return }

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
