//
//  NetworkManager.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

import Foundation

protocol NetworkManagerProtocol: Sendable {
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint, type: T.Type) async throws -> T
}

final class NetworkManager: NetworkManagerProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint, type: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod
        request.httpBody = endpoint.httpBody
                
        // 2. Default Headers  (which will go in every api)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 3. Custom Headers (specific to this api call if any)
        if let customHeaders = endpoint.customHeaders {
            for (key, value) in customHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
#if DEBUG
        logRequest(request)
#endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
#if DEBUG
        logResponse(httpResponse, data: data)
#endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badRequest(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            // Open-Meteo uses snake_case in API keys
           // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("🛑 [NetworkManager] Unknown Fetch Exception: \(error.localizedDescription)")
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Helper Logging Functions
    #if DEBUG
    private func logRequest(_ request: URLRequest) {
        print("\n🌐 -------------------- OUTGOING REQUEST --------------------")
        print("🔗 URL:    \(request.url?.absoluteString ?? "N/A")")
        print("⚡ METHOD: \(request.httpMethod ?? "GET")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 HEADERS:")
            for (key, value) in headers {
                print("   ▪️ \(key): \(value)")
            }
        }
        
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📦 BODY Payload:\n\(bodyString)")
        }
        print("-----------------------------------------------------------\n")
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        print("\n📥 -------------------- INCOMING RESPONSE --------------------")
        print("🔗 URL:     \(response.url?.absoluteString ?? "N/A")")
        let statusIcon = (200...299).contains(response.statusCode) ? "🟢" : "🔴"
        print("\(statusIcon) STATUS:  \(response.statusCode)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📝 RAW DATA PAYLOAD:")
            if jsonString.count > 1000 {
                print("\(jsonString.prefix(1000))...\n👉 [Log Truncated - Output exceeded 1000 characters]")
            } else {
                print(jsonString)
            }
        }
        print("-----------------------------------------------------------\n")
    }
    #endif
}

