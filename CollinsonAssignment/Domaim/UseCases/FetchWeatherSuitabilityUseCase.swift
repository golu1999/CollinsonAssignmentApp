//
//  FetchWeatherSuitabilityUseCase.swift
//  CollinsonAssignment
//
//  Created by hardik on 18/10/26.
//

import Foundation

protocol FetchWeatherSuitabilityUseCaseProtocol: Sendable {
    func execute(for city: CityLocation) async throws -> [DailySuitability]
}

final class FetchWeatherSuitabilityUseCase: FetchWeatherSuitabilityUseCaseProtocol {
    
    private let repository: WeatherRepositoryProtocol
    private let suitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol
    
    
    init(repository: WeatherRepositoryProtocol = WeatherRepository(), suitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol = CalculateActivitySuitabilityUseCase()) {
        self.repository = repository
        self.suitabilityUseCase = suitabilityUseCase
    }
    
    func execute(for city: CityLocation) async throws -> [DailySuitability] {
        // 1. Fetch the raw data from the data gateway abstraction
        let suitabilityData = try await repository.fetchDailySuitability(for: city)
        
        // 2. Pass it to the localized scoring domain use case to calculate rankings
        let processedSuitability = suitabilityUseCase.execute(with: suitabilityData)
        return processedSuitability
    }
}

