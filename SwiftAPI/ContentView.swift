//
//  ContentView.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            
            //EZ_Flip-removebg-preview 1
            Image("EZ_Flip-removebg-preview 1")
                .resizable().scaledToFill().frame(height: 350)
        
            ZStack {
                // Background border box
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .background(Color.white.opacity(0.2))
                    .frame(width: 350, height: 300)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding() // Adds internal spacing
                        .frame(height: 45) // Makes text field taller
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                      
                    SecureField("Password", text: $password)
                        .padding() // Adds internal spacing
                        .frame(height: 45) // Makes text field taller
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    
                    Button(action: {}) {
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
                        Button(action: {}) {
                            Text("Forgot password?")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        Button(action: {}) {
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
                }
                .padding()
            }
            //Text("SwiftAPI").font(.system(size: 22, weight: .medium)).foregroundColor(.appColor).padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
