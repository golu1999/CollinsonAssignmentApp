//
//  NetworkError.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest(Int)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .badRequest(let statusCode):
            return "Server responded with a bad status code: \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode the response data: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

