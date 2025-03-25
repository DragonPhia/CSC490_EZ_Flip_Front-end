//
//  SupabaseService.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//  SupaBase for Inventory
//

import Foundation

struct InventoryItem: Identifiable, Codable {
    var id: String
    var name: String
    var purchase_price: Double?
    var selling_price: Double?
    var storage_location: String?
    var notes: String?
    var status: String
    var date_added: String
}

class SupabaseService {
    static let shared = SupabaseService()
    
    private let baseURL = URL(string: "https://nscfwqcjtpkfweokcqha.supabase.co/rest/v1/inventory_items")!
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zY2Z3cWNqdHBrZndlb2tjcWhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5MjExOTQsImV4cCI6MjA1ODQ5NzE5NH0.H01O0pudHfAG5i0fmAyNxdgvK_-UbsZSosBvWKwfA3Y"
    
    private var requestHeaders: [String: String] {
        [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        ]
    }

    func fetchItems(completion: @escaping (Result<[InventoryItem], Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = requestHeaders
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return }
            
            do {
                let items = try JSONDecoder().decode([InventoryItem].self, from: data)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func addItem(_ item: InventoryItem, completion: @escaping (Result<InventoryItem, Error>) -> Void) {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders

        do {
            let body = try JSONEncoder().encode(item)
            request.httpBody = body
            
            // ✅ Log outgoing JSON
            print("📤 SENDING TO SUPABASE:")
            print(String(data: body, encoding: .utf8) ?? "Invalid JSON")
            
        } catch {
            print("❌ Encoding Error: \(error)")
            return completion(.failure(error))
        }

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
                // ✅ Log raw response before decoding
                print("📥 RAW RESPONSE FROM SUPABASE:")
                print(String(data: data, encoding: .utf8) ?? "Invalid response")

                let newItem = try JSONDecoder().decode([InventoryItem].self, from: data).first!
                completion(.success(newItem))
            } catch {
                print("❌ Decode Error: \(error)")
                print("🧾 Response Dump: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
                completion(.failure(error))
            }
        }.resume()
    }


    func updateItem(_ item: InventoryItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?id=eq.\(item.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = requestHeaders
        
        do {
            let body = try JSONEncoder().encode(item)
            request.httpBody = body
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }

    func deleteItem(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?id=eq.\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = requestHeaders

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ DELETE failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Item deleted from Supabase")
                completion(.success(()))
            }
        }.resume()
    }

}
