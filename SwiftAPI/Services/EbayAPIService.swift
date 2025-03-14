//
//  APIService.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/27/25.
//

import Foundation

class EbayAPIService {
    static let shared = EbayAPIService() // Singleton instance
    
    private init() {}

    func searchItems(query: String, completion: @escaping (Result<[EbayItem], Error>) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/search?query=\(query)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil))) }
                return
            }

            // Debug: Print out the raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")  // Print raw JSON to debug
            }

            do {
                let responseWrapper = try JSONDecoder().decode(EbayResponseWrapper.self, from: data)

                // Check if activeListings is empty
                if responseWrapper.activeListings.isEmpty {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No listings found", code: 404, userInfo: nil)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(responseWrapper.activeListings))
                    }
                }
            } catch {
                // Handle decoding error and print error for debugging
                DispatchQueue.main.async {
                    print("Error decoding response: \(error.localizedDescription)")
                    completion(.failure(error))  // Pass error back to the caller
                }
            }
        }
        task.resume()
    }
}
