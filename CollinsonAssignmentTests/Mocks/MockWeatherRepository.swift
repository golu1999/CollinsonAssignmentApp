//
//  MockWeatherRepository.swift
//  CollinsonAssignmentTests
//
//  Created by hardik on 18/10/26.
//

import Foundation
@testable import CollinsonAssignment

final class MockWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    var mockCitiesResult: [CityLocation] = []
    var mockSuitabilityResult: WeatherResponse?
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.invalidResponse
    
    func searchCities(named name: String) async throws -> [CityLocation] {
        if shouldThrowError { throw errorToThrow }
        return mockCitiesResult
    }
    
    func fetchDailySuitability(for city: CityLocation) async throws -> WeatherResponse {
        if shouldThrowError { throw errorToThrow }
        if let result = mockSuitabilityResult { return result }
        throw NetworkError.invalidResponse
    }
}

