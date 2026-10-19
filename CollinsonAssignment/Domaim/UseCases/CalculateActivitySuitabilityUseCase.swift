//
//  CalculateActivitySuitabilityUseCase.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

protocol CalculateActivitySuitabilityUseCaseProtocol: Sendable {
    func execute(with weather: WeatherResponse) -> [DailySuitability]
}

final class CalculateActivitySuitabilityUseCase: CalculateActivitySuitabilityUseCaseProtocol {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    func execute(with weather: WeatherResponse) -> [DailySuitability] {
        var result: [DailySuitability] = []
        let dailyData = weather.daily
        
        
        for i in 0..<dailyData.time.count {
            guard dailyData.time.indices.contains(i),
                  dailyData.temperature2mMax.indices.contains(i),
                  dailyData.precipitationSum.indices.contains(i),
                  dailyData.snowfallSum.indices.contains(i),
                  dailyData.windSpeed10mMax.indices.contains(i) else { continue }
            
            let dateString = dailyData.time[i]
            let date = dateFormatter.date(from: dateString) ?? Date()
            let displayDate = displayFormatter.string(from: date)
            
            
            let maxTemp = dailyData.temperature2mMax[i]
            let precipitation = dailyData.precipitationSum[i]
            let snowfall = dailyData.snowfallSum[i]
            let windSpeed = dailyData.windSpeed10mMax[i]
            let weatherCode = dailyData.weatherCode[i]
            
            
            let skiingScore = calculateSkiingScore(maxTemp: maxTemp, snowfall: snowfall, weatherCode: weatherCode)
            let surfingScore = calculateSurfingScore(windSpeed: windSpeed, precipitation: precipitation, maxTemp: maxTemp)
            let outdoorScore = calculateOutdoorScore(maxTemp: maxTemp, precipitation: precipitation, windSpeed: windSpeed)
            let indoorScore = calculateIndoorScore(precipitation: precipitation, maxTemp: maxTemp)
            
            let activities = [
                ActivityScore(name: "Skiing", score: skiingScore, rating: mapToRating(skiingScore)),
                ActivityScore(name: "Surfing", score: surfingScore, rating: mapToRating(surfingScore)),
                ActivityScore(name: "Outdoor Sightseeing", score: outdoorScore, rating: mapToRating(outdoorScore)),
                ActivityScore(name: "Indoor Sightseeing", score: indoorScore, rating: mapToRating(indoorScore))
            ]
            
            result.append(DailySuitability(date: date, displayDate: displayDate, activities: activities))
        }
        
        return result
    }
    
    // MARK: - Core Algorithms (Senior Business Judgment)
    
    private func calculateSkiingScore(maxTemp: Double, snowfall: Double, weatherCode: Int) -> Int {
        
        if maxTemp > 5.0 { return 0 }
        
        var score = 50
        if snowfall > 0 { score += 30 }
        if maxTemp <= 0 { score += 20 }
        
        // WMO Codes: 71, 73, 75 मतलब Snowfall है
        if [71, 73, 75, 77, 85, 86].contains(weatherCode) { score += 10 }
        
        return min(100, max(0, score))
    }
    
    private func calculateSurfingScore(windSpeed: Double, precipitation: Double, maxTemp: Double) -> Int {
        
        if maxTemp < 10.0 { return 10 } // बहुत ज्यादा ठंडा मौसम
        if windSpeed < 5.0 { return 0 }  // हवा नहीं तो वेव्स (Waves) नहीं
        
        var score = 40
        if (12...28).contains(windSpeed) { score += 40 } // परफेक्ट विंड रेंज
        if precipitation == 0 { score += 20 }
        
        return min(100, max(0, score))
    }
    
    private func calculateOutdoorScore(maxTemp: Double, precipitation: Double, windSpeed: Double) -> Int {
        
        if precipitation > 5.0 { return 10 }
        
        var score = 100
        
        score -= Int(precipitation * 10)
        
        
        if maxTemp < 15.0 || maxTemp > 30.0 { score -= 30 } 
        if windSpeed > 25.0 { score -= 20 }
        
        return min(100, max(0, score))
    }
    
    private func calculateIndoorScore(precipitation: Double, maxTemp: Double) -> Int {
        
        var score = 50
        
        if precipitation > 2.0 { score += 30 }
        if maxTemp < 10.0 || maxTemp > 32.0 { score += 20 } 
        
        return min(100, max(0, score))
    }
    
    private func mapToRating(_ score: Int) -> SuitabilityRating {
        switch score {
        case 80...100: return .perfect
        case 50..<80: return .good
        case 20..<50: return .poor
        default: return .unsuitable
        }
    }
}

