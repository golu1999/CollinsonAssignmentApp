//
//  WeatherRepositoryProtocol.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

protocol WeatherRepositoryProtocol: Sendable {
    func searchCities(named name: String) async throws -> [CityLocation]
    func fetchDailySuitability(for city: CityLocation) async throws -> WeatherResponse
}
