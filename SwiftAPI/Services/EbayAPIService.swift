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

            do {
                let responseWrapper = try JSONDecoder().decode(EbayResponseWrapper.self, from: data)
                let items = responseWrapper.findItemsByKeywordsResponse.first?.searchResult?.first?.item ?? []
                DispatchQueue.main.async { completion(.success(items)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        task.resume()
    }
}
