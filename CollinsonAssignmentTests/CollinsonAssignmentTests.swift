//
//  CollinsonAssignmentTests.swift
//  CollinsonAssignmentTests
//
//  Created by hardik on 16/10/26.
//

import XCTest
@testable import CollinsonAssignment

final class CollinsonAssignmentTests: XCTestCase {
    
    private var mockRepository: MockWeatherRepository!
    
    
    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRepository()
    }
    
    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
        
    
    // MARK: - SearchViewModel Tests
        
        @MainActor
        func testSearchViewModel_WhenQueryChanges_PopulatesCitiesSuccessfully() async {
            // Arrange
            let expectedCity = CityLocation(id: 1, name: "Zurich", latitude: 47.37, longitude: 8.54, country: "Switzerland", admin1: "Zurich")
            mockRepository.mockCitiesResult = [expectedCity]
            
            let mockSearchUseCase = SearchCitiesUseCase(repository: mockRepository)
            let sut = SearchViewModel(searchCitiesUseCase: mockSearchUseCase)
            
            // Act
            sut.searchQuery = "Zurich"
            
            // Wait briefly for the 300ms debouncing window inside SearchViewModel to execute
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            // Assert
            XCTAssertFalse(sut.isLoading)
            XCTAssertEqual(sut.cities.count, 1)
            XCTAssertEqual(sut.cities.first?.name, "Zurich")
            XCTAssertNil(sut.errorMessage)
        }
        
        @MainActor
        func testSearchViewModel_WhenAPIFails_ReturnsCleanErrorMessage() async {
            // Arrange
            mockRepository.shouldThrowError = true
            
            let mockSearchUseCase = SearchCitiesUseCase(repository: mockRepository)
            let sut = SearchViewModel(searchCitiesUseCase: mockSearchUseCase)
            
            // Act
            sut.searchQuery = "InvalidCity"
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            // Assert
            XCTAssertFalse(sut.isLoading)
            XCTAssertTrue(sut.cities.isEmpty)
            XCTAssertNotNil(sut.errorMessage)
        }
        
        // MARK: - Business Logic Algorithm Tests
        
        func testCalculateActivitySuitabilityUseCase_WhenWeatherIsFreezingAndSnowing_SkiingIsPerfect() {
            // Arrange
            let useCase = CalculateActivitySuitabilityUseCase()
            
            // Mocking a perfect winter weather matrix
            let mockDaily = DailyWeatherData(
                time: ["2026-12-25"],
                temperature2mMax: [-2.0], // Below freezing
                temperature2mMin: [-7.0],
                precipitationSum: [4.0],
                snowfallSum: [5.0],       // Fresh heavy snow
                windSpeed10mMax: [10.0],
                weatherCode: [75]         // WMO Heavy Snow code
            )
            let mockResponse = WeatherResponse(latitude: 46.0, longitude: 7.0, timezone: "GMT", daily: mockDaily)
            
            // Act
            let results = useCase.execute(with: mockResponse)
            
            // Assert
            XCTAssertEqual(results.count, 1)
            let skiingActivity = results.first?.activities.first(where: { $0.name == "Skiing" })
            
            XCTAssertNotNil(skiingActivity)
            XCTAssertEqual(skiingActivity?.rating, .perfect)
            XCTAssertGreaterThanOrEqual(skiingActivity?.score ?? 0, 80)
        }
        
    func testCalculateActivitySuitabilityUseCase_WhenWeatherIsTooHot_SkiingIsUnsuitable() {
        // Arrange
        let useCase = CalculateActivitySuitabilityUseCase()
        
        // Mocking a hot summer weather matrix
        let mockDaily = DailyWeatherData(
            time: ["2026-07-15"],
            temperature2mMax: [32.0], // Boiling hot
            temperature2mMin: [20.0],
            precipitationSum: [0.0],
            snowfallSum: [0.0],
            windSpeed10mMax: [5.0],
            weatherCode: [0]
        )
        let mockResponse = WeatherResponse(latitude: 46.0, longitude: 7.0, timezone: "GMT", daily: mockDaily)
        
        // Act
        let results = useCase.execute(with: mockResponse)
        
        // Assert
        let skiingActivity = results.first?.activities.first(where: { $0.name == "Skiing" })
        XCTAssertEqual(skiingActivity?.rating, .unsuitable)
        XCTAssertEqual(skiingActivity?.score, 0)
    }
            

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
