//
//  GeocodingResponse.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

nonisolated struct GeocodingResponse: Codable, Sendable {
    let results: [CityLocation]?
}

nonisolated struct CityLocation: Codable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String? // States or Provinces (e.g., California)
    
    var displayLocation: String {
        let parts = [name, admin1, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: ", ")
    }
}
