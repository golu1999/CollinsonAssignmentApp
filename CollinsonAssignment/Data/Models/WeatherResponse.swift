//
//  WeatherResponse.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

import Foundation

nonisolated struct WeatherResponse: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let daily: DailyWeatherData
}

nonisolated struct DailyWeatherData: Codable, Sendable {
    let time: [String] // Dates (YYYY-MM-DD)
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationSum: [Double]
    let snowfallSum: [Double]
    let windSpeed10mMax: [Double]
    let weatherCode: [Int] // WMO Weather interpretation codes
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMax = "wind_speed_10m_max"
        case weatherCode = "weather_code"
    }
}
