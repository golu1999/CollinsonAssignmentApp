//
//  ActivitySuitability.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation

enum SuitabilityRating: String, Sendable, Codable {
    case perfect = "Perfect"
    case good = "Good"
    case poor = "Poor"
    case unsuitable = "Unsuitable"
    
    var icon: String {
        switch self {
        case .perfect: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .poor: return "hand.thumbsdown.fill"
        case .unsuitable: return "xmark.octagon.fill"
        }
    }
}

struct ActivityScore: Sendable, Identifiable {
    let id = UUID()
    let name: String // "Skiing", "Surfing", etc.
    let score: Int // 0 to 100
    let rating: SuitabilityRating
}

struct DailySuitability: Sendable, Identifiable {
    let id = UUID()
    let date: Date
    let displayDate: String // e.g., "Monday, Oct 16"
    let activities: [ActivityScore]
}

