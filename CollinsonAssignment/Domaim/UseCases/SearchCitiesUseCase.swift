//
//  SearchCitiesUseCase.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

protocol SearchCitiesUseCaseProtocol: Sendable {
    func execute(named name: String) async throws -> [CityLocation]
}

final class SearchCitiesUseCase: SearchCitiesUseCaseProtocol {
    
    private let repository: WeatherRepositoryProtocol
    
    // Use Case depends directly on Repository Protocol 
    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }
    
    func execute(named name: String) async throws -> [CityLocation] {
        
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedName.isEmpty else {
            return []
        }
        
        return try await repository.searchCities(named: cleanedName)
    }
}

