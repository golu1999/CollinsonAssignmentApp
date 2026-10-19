//
//  MockCalculateActivitySuitabilityUseCase.swift
//  CollinsonAssignmentTests
//
//  Created by hardik on 18/10/26.
//

import Foundation
@testable import CollinsonAssignment

final class MockCalculateActivitySuitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol, @unchecked Sendable {
    var mockResult: [DailySuitability] = []
    
    func execute(with weather: WeatherResponse) -> [DailySuitability] {
        return mockResult
    }
}

