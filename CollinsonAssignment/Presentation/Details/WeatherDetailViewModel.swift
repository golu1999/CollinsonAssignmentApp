//
//  WeatherDetailViewModel.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation
import Combine

@MainActor
final class WeatherDetailViewModel: ObservableObject {
    
    @Published private(set) var suitabilityDays: [DailySuitability] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private let fetchWeatherUseCase: FetchWeatherSuitabilityUseCaseProtocol
    private let city: CityLocation
    
    init(city: CityLocation, repository: FetchWeatherSuitabilityUseCaseProtocol = FetchWeatherSuitabilityUseCase()) {
        self.city = city
        self.fetchWeatherUseCase = repository
    }
    
    func loadWeatherData() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let processedData = try await fetchWeatherUseCase.execute(for: city)
            self.suitabilityDays = processedData
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}

