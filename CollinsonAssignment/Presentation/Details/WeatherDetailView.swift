//
//  WeatherDetailView.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import SwiftUI

struct WeatherDetailView: View {
    let city: CityLocation
    @StateObject private var viewModel: WeatherDetailViewModel
    
    // Custom Initailization for dependency injection
    init(city: CityLocation) {
        self.city = city
        self._viewModel = StateObject(wrappedValue: WeatherDetailViewModel(city: city))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Analyzing 7-day weather compatibility...")
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView {
                    Label("Error Loading Data", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.loadWeatherData() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                
                List(viewModel.suitabilityDays) { day in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(day.displayDate)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.top, 4)
                        
                        // Scorecard of that specific day
                        ForEach(day.activities) { activity in
                            HStack {
                                Image(systemName: activity.rating.icon)
                                    .font(.title3)
                                    .foregroundColor(colorForRating(activity.rating))
                                    .frame(width: 30)
                                
                                Text(activity.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("\(activity.rating.rawValue) (\(activity.score)%)")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.visible) 
            }
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        // This will call API immediately after loading the screen
        .task {
            await viewModel.loadWeatherData()
        }
    }
    
    // Choosing color according to the rating
    private func colorForRating(_ rating: SuitabilityRating) -> Color {
        switch rating {
        case .perfect: return .green
        case .good: return .blue
        case .poor: return .orange
        case .unsuitable: return .red
        }
    }
}


