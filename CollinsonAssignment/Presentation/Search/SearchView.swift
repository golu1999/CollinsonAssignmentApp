//
//  SearchView.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import SwiftUI

struct SearchView: View {
    // ViewModel
    @StateObject private var viewModel: SearchViewModel = SearchViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                // 1. Search Bar with state-driven binding
                TextField("Search for a city or town...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                // 2. Conditional UI States (Loading, Error, List, Empty)
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching locations...")
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    ContentUnavailableView {
                        Label("Search Failed", systemImage: "exclamationmark.triangle.fill")
                    } description: {
                        Text(error)
                    }
                    Spacer()
                } else if viewModel.cities.isEmpty && !viewModel.searchQuery.isEmpty {
                    Spacer()
                    ContentUnavailableView {
                        Label("No Results", systemImage: "mappin.slash")
                    } description: {
                        Text("No matching cities found for '\(viewModel.searchQuery)'.")
                    }
                    Spacer()
                } else if viewModel.searchQuery.isEmpty {
                    Spacer()
                    ContentUnavailableView {
                        Label("Find a Destination", systemImage: "magnifyingglass")
                    } description: {
                        Text("Type a city name to analyze suitability for skiing, surfing, and sightseeing.")
                    }
                    Spacer()
                } else {
                    // 3. Results list successfully comes.
                    List(viewModel.cities) { city in
                        // When user will click on city, navigation gets triggered
                        NavigationLink(destination: WeatherDetailView(city: city)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.headline)
                                if city.country != nil {
                                    Text(city.displayLocation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Collinson Weather App")
        }
    }
}
