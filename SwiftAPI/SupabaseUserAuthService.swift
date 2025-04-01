//
//  SupabaseUserAuthService.swift
//  SwiftAPI
//
//  Created by Dragon P on 3/31/25.
//

import Foundation
import Supabase
import SwiftUI

class SupabaseUserAuthService {
    static let shared = SupabaseUserAuthService()

    // Supabase URL and key (replace with actual values)
    private let supabaseURL = URL(string: "https://your-project-id.supabase.co")!  // Replace with your Supabase URL
    private let supabaseKey = "your-public-anon-key"  // Replace with your Supabase public anon key

    // Define a struct that conforms to Encodable and Decodable
    struct UserData: Codable {  // Ensure UserData conforms to Codable (which includes Decodable)
        let name: String
        let email: String
        let accessToken: String
        let refreshToken: String
    }

    // Function to save user info to Supabase
    func saveUserInfo(name: String, email: String, accessToken: String, refreshToken: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let userData = UserData(name: name, email: email, accessToken: accessToken, refreshToken: refreshToken)

        // Create the request to Supabase
        var request = URLRequest(url: supabaseURL.appendingPathComponent("users"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")  // Add authorization if needed

        do {
            let body = try JSONEncoder().encode(userData)
            request.httpBody = body

            // Log the outgoing JSON
            print("📤 SENDING TO SUPABASE:")
            print(String(data: body, encoding: .utf8) ?? "Invalid JSON")
            
        } catch {
            print("❌ Encoding Error: \(error)")
            return completion(.failure(error))
        }

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                return completion(.failure(error))
            }

            guard let data = data else {
                print("❌ No response data")
                return
            }

            do {
                // Log the raw response before decoding
                print("📥 RAW RESPONSE FROM SUPABASE:")
                print(String(data: data, encoding: .utf8) ?? "Invalid response")

                // Decode the response into the UserData struct
                let newUser = try JSONDecoder().decode([UserData].self, from: data).first!
                completion(.success(newUser))
            } catch {
                print("❌ Decode Error: \(error)")
                print("🧾 Response Dump: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
                completion(.failure(error))
            }
        }.resume()
    }
}
