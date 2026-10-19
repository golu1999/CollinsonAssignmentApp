//
//  APIEndPoint.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

enum APIEndpoint {
    case geocode(cityName: String)
    case forecast(latitude: Double, longitude: Double)
    
    
    var baseAPIURL: String {
        switch self {
        case .geocode:
            return "geocoding-api.open-meteo.com"
        case .forecast:
            return "api.open-meteo.com"
        }
    }
    
    var scheme: String {
        return "https"
    }
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = baseAPIURL
        switch self {
        case .geocode(let cityName):
            components.path = "/v1/search"
            components.queryItems = [
                URLQueryItem(name: "name", value: cityName),
                URLQueryItem(name: "count", value: "5"),
                URLQueryItem(name: "language", value: "en"),
                URLQueryItem(name: "format", value: "json")
            ]
            
        case .forecast(let lat, let lon):
            components.path = "/v1/forecast"
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(lat)),
                URLQueryItem(name: "longitude", value: String(lon)),
                // 7 days forecast queries required by prompt
                URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,precipitation_sum,snowfall_sum,wind_speed_10m_max,weather_code"),
                URLQueryItem(name: "timezone", value: "auto")
            ]
        }
        return components.url
    }
    
    // CUSTOM HEADERS IF ANY FOR THIS API APART FROM NORMAL HEADERS
    
    var customHeaders: [String: String]? {
            switch self {
            case .geocode, .forecast:
                return nil
            }
        }
    
    var httpMethod: String {
        switch self {
        case .geocode, .forecast:
            return "GET"
        }
    }
    
    var httpBody: Data? {
            switch self {
            case .geocode, .forecast:
                return nil
            }
        }
}

