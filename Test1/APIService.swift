//
//  APIService.swift
//  Test1
//
//  Created by Sri Harsha on 17/05/25.
//

import Foundation

class APIService {
    /// Makes a GET request to the specified endpoint
    /// - Parameter completion: Completion handler with Result containing string response or error
    static func fetchData(completion: @escaping (Result<String, Error>) -> Void) {
        // Use localhost instead of 127.0.0.1 (they're equivalent but sometimes localhost works better)
        let urlString = "http://localhost:3000/api/ai/test"
        
        guard let url = URL(string: urlString) else {
            let errorMessage = "Failed to create URL from: \(urlString)"
            print(errorMessage)
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return 
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("Starting GET request to \(urlString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let errorMessage = "Invalid response type"
                print(errorMessage)
                completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = "HTTP error: status code \(httpResponse.statusCode)"
                print(errorMessage)
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            if let data = data {
                if let stringResponse = String(data: data, encoding: .utf8) {
                    print("Received response: \(stringResponse)")
                    completion(.success(stringResponse))
                } else {
                    let errorMessage = "Failed to decode response data as UTF-8 string"
                    print(errorMessage)
                    completion(.failure(NSError(domain: "DataDecoding", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            } else {
                let errorMessage = "No data received in response"
                print(errorMessage)
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }
        
        task.resume()
    }
    
    /// Makes a POST request with a JSON payload
    /// - Parameters:
    ///   - endpoint: The API endpoint path (will be appended to the base URL)
    ///   - payload: Dictionary containing the data to send as JSON
    ///   - completion: Completion handler with Result containing string response or error
    static func postData(endpoint: String, payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        let baseURL = "http://localhost:3000"
        let urlString = baseURL + endpoint
        
        guard let url = URL(string: urlString) else {
            let errorMessage = "Failed to create URL from: \(urlString)"
            print(errorMessage)
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            return
        }
        
        // Convert dictionary to JSON data
        do {
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Set the POST data
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            
            print("Starting POST request to \(urlString) with payload: \(payload)")
            
            // Create and start the task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let errorMessage = "Invalid response type"
                    print(errorMessage)
                    completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorMessage = "HTTP error: status code \(httpResponse.statusCode)"
                    print(errorMessage)
                    completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                if let data = data {
                    if let stringResponse = String(data: data, encoding: .utf8) {
                        print("Received response: \(stringResponse)")
                        completion(.success(stringResponse))
                    } else {
                        let errorMessage = "Failed to decode response data as UTF-8 string"
                        print(errorMessage)
                        completion(.failure(NSError(domain: "DataDecoding", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                } else {
                    let errorMessage = "No data received in response"
                    print(errorMessage)
                    completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            }
            
            task.resume()
            
        } catch {
            let errorMessage = "Failed to serialize JSON payload: \(error.localizedDescription)"
            print(errorMessage)
            completion(.failure(NSError(domain: "JSONSerialization", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
        }
    }
}
