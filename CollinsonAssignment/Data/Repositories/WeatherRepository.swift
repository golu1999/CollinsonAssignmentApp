//
//  WeatherRepository.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

final class WeatherRepository: WeatherRepositoryProtocol {
    
    private let networkManager: NetworkManagerProtocol
    private let suitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol
    
    // Dependency Injection
    init(
        networkManager: NetworkManagerProtocol = NetworkManager(),
        suitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol = CalculateActivitySuitabilityUseCase()
    ) {
        self.networkManager = networkManager
        self.suitabilityUseCase = suitabilityUseCase
    }
    
    func searchCities(named name: String) async throws -> [CityLocation] {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        let response = try await networkManager.fetch(.geocode(cityName: name), type: GeocodingResponse.self)
        return response.results ?? []
    }
    
    func fetchDailySuitability(for city: CityLocation) async throws -> WeatherResponse {
        return try await networkManager.fetch(
            .forecast(latitude: city.latitude, longitude: city.longitude),
            type: WeatherResponse.self
        )
    }
}

