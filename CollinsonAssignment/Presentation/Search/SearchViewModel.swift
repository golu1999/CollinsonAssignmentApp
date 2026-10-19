//
//  SearchViewModel.swift
//  CollinsonAssignment
//
//  Created by hardik on 16/10/26.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    
    
    // MARK: - Published States for UI
    @Published var searchQuery: String = "" {
        didSet {
            // As soon as user types text , debounce starts
            searchQueryChanged()
        }
    }
    
    @Published private(set) var cities: [CityLocation] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    // MARK: - Dependencies
    private let searchCitiesUseCase: SearchCitiesUseCaseProtocol
    
    private var lastSearchedQuery: String = ""
    
    // keep Active Search Task Referance so that we can cancel it later on if needed
    private var searchTask: Task<Void, Never>?
    
    // Dependency Injection
        init(searchCitiesUseCase: SearchCitiesUseCaseProtocol = SearchCitiesUseCase()) {
            self.searchCitiesUseCase = searchCitiesUseCase
        }
    
    // MARK: - Search Logic with Debouncing
    
    private func searchQueryChanged() {
       
        searchTask?.cancel()
        
        let cleanedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleanedQuery != lastSearchedQuery else { return }
        
        guard !cleanedQuery.isEmpty else {
            self.cities = []
            self.errorMessage = nil
            self.isLoading = false
            return
        }
        
    
        searchTask = Task {
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            
            if Task.isCancelled { return }
            
            self.isLoading = true
            self.errorMessage = nil
            
            do {
                
                let fetchedCities = try await searchCitiesUseCase.execute(named: cleanedQuery)
                
                if Task.isCancelled { return }
                
                self.cities = fetchedCities
                self.isLoading = false
            } catch {
                if Task.isCancelled { return }
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.cities = []
            }
        }
    }
    

    deinit {
        searchTask?.cancel()
    }
}

