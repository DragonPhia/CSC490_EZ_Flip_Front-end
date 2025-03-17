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

    func searchItems(query: String, completion: @escaping (Result<EbayResponseWrapper, Error>) -> Void) {
        guard let url = URL(string: "https://ezflip.onrender.com/api/search?query=\(query)") else {
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

            // Print raw data for debugging
            if let rawString = String(data: data, encoding: .utf8) {
                print("Raw response data: \(rawString)")
            }

            do {
                let responseWrapper = try JSONDecoder().decode(EbayResponseWrapper.self, from: data)
                print("Decoded Response: \(responseWrapper)")
                DispatchQueue.main.async {
                    completion(.success(responseWrapper))
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding response: \(error.localizedDescription)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(dataString)") // Log the response for debugging
                    }
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
