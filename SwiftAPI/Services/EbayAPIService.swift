//
//  APIService.swift
//  SwiftAPI
//
//  Created by Dragon P on 2/27/25.
//

import Foundation
import Combine
import UIKit

struct EbayAPIResponse: Codable {
    let averageListedPrice: String
    let totalActiveListings: Int
    let activeListings: [EbayItem]
    
    // Make highestPrice and lowestPrice optional
    let highestPrice: String?
    let lowestPrice: String?
}

class EbayAPIService {
    static let baseURL = "https://ezflip.onrender.com/api/search?query="
    static let imageSearchURL = "https://ezflip.onrender.com/api/image-search"

    static func fetchItems(query: String) -> AnyPublisher<EbayAPIResponse, Error> {
        let urlString = baseURL + query
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { response in
                // Log the raw response to debug
//                if let body = String(data: response.data, encoding: .utf8) {
//                    print("Response Body: \(body)")  // Log the raw response body
//                }
                return response.data
            }
            .decode(type: EbayAPIResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // New function for image-based search (using multipart/form-data)
    static func searchByImage(image: UIImage) -> AnyPublisher<EbayAPIResponse, Error> {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: URL(string: imageSearchURL)!)
        request.httpMethod = "POST"
        
        // Create boundary string for multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create body
        var body = Data()
        let fileName = "image.jpg"
        
        // Add image to body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End of body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response in
                // Log the raw response to debug
//                if let body = String(data: response.data, encoding: .utf8) {
//                    print("Image Search Response Body: \(body)")  // Log the raw response body
//                }
                
                // Handle error in the response (if backend sends error message)
                if let errorMessage = try? JSONDecoder().decode([String: String].self, from: response.data),
                   let error = errorMessage["error"] {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error])
                }
                
                return response.data
            }
            .decode(type: EbayAPIResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
