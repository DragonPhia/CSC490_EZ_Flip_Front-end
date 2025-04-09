//
//  SupabaseService.swift
//  SwiftAPI
//
//  Created by Emmanuel G on 3/25/25.
//  SupaBase integration with image upload corrected
//

import Foundation
import PostgREST
import Storage

struct InventoryItem: Identifiable, Codable {
    var id: String
    var name: String
    var purchase_price: Double?
    var selling_price: Double?
    var storage_location: String?
    var notes: String?
    var status: String
    var date_added: String
    var imageURL: String?
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

        URLSession.shared.dataTask(with: request) { data, _, error in
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
        request.httpBody = try? JSONEncoder().encode(item)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return }

            do {
                let newItem = try JSONDecoder().decode([InventoryItem].self, from: data).first!
                completion(.success(newItem))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func updateItem(_ item: InventoryItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?id=eq.\(item.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = try? JSONEncoder().encode(item)

        URLSession.shared.dataTask(with: request) { _, _, error in
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

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }

    // MARK: - Corrected Image Upload
    func uploadImage(data: Data, for itemID: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let bucketName = "ezflip-images"
        let path = "images/\(itemID).jpg"
        let url = URL(string: "https://nscfwqcjtpkfweokcqha.supabase.co/storage/v1/object/\(bucketName)/\(path)")!

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        URLSession.shared.uploadTask(with: request, from: data) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let publicURL = URL(string: "https://nscfwqcjtpkfweokcqha.supabase.co/storage/v1/object/public/\(bucketName)/\(path)")!
            completion(.success(publicURL))
        }.resume()
    }
}
