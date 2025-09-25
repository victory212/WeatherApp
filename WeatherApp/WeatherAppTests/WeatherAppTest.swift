//
//  WeatherAppTest.swift
//  WeatherAppTests
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import Testing
import Foundation
@testable import WeatherApp

// MARK: - Mock Services

@MainActor
final class MockWeatherService: WeatherServiceProtocol {
    var shouldThrowError = false
    var weatherResponse: WeatherResponse?
    var fetchWeatherCalled = false
    var fetchWeatherCalledWith: String?
    var errorToThrow: Error = URLError(.networkConnectionLost)
    
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        fetchWeatherCalled = true
        fetchWeatherCalledWith = city
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return weatherResponse ?? WeatherResponse.mock()
    }
}

final class MockFavoritesStore: FavoritesStore {
    private var storedCity: String?
    var saveCalled = false
    var saveCalledWith: String?
    var loadCalled = false
    
    override init(defaults: UserDefaults = .standard) {
        super.init(defaults: defaults)
    }
    
    override func save(city: String) {
        saveCalled = true
        saveCalledWith = city
        storedCity = city
    }
    
    override func load() -> String? {
        loadCalled = true
        return storedCity
    }
    
    // Helper method for testing
    func setStoredCity(_ city: String?) {
        storedCity = city
    }
}

// MARK: - Mock Data Extensions

extension WeatherResponse {
    static func mock(
        name: String = "London",
        temperature: Double = 293.15, // 20°C in Kelvin
        description: String = "clear sky"
    ) -> WeatherResponse {
        return WeatherResponse(
            weather: [Weather(description: description)],
            main: Main(temp: temperature),
            name: name
        )
    }
}

// MARK: - Tests

@MainActor
struct HomeViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization_WithNoFavorite() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        #expect(viewModel.city == "")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.weather == nil)
        #expect(mockFavoritesStore.loadCalled == true)
    }
    
    @Test func testInitialization_WithFavorite() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        mockFavoritesStore.setStoredCity("New York")
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        #expect(viewModel.city == "New York")
        #expect(mockFavoritesStore.loadCalled == true)
    }
    
    // MARK: - Fetch Weather Tests
    
    @Test func testFetchWeather_Success() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse.mock(
            name: "London",
            temperature: 298.15, // 25°C in Kelvin
            description: "sunny"
        )
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "London"
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == true)
        #expect(mockWeatherService.fetchWeatherCalledWith == "London")
        #expect(viewModel.weather?.name == "London")
        #expect(viewModel.weather?.main.temp == 298.15)
        #expect(viewModel.weather?.weather.first?.description == "sunny")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testFetchWeather_TrimsWhitespace() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse.mock(name: "Paris")
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "  Paris  "
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalledWith == "Paris")
        #expect(viewModel.weather?.name == "Paris")
    }
    
    @Test func testFetchWeather_EmptyCity() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = ""
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == false)
        #expect(viewModel.errorMessage == "Please enter a city name")
        #expect(viewModel.weather == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testFetchWeather_WhitespaceOnlyCity() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "   "
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == false)
        #expect(viewModel.errorMessage == "Please enter a city name")
        #expect(viewModel.weather == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testFetchWeather_NetworkError() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        mockWeatherService.shouldThrowError = true
        mockWeatherService.errorToThrow = URLError(.networkConnectionLost)
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "London"
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == true)
        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testFetchWeather_BadServerResponseError() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        mockWeatherService.shouldThrowError = true
        mockWeatherService.errorToThrow = URLError(.badServerResponse)
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "InvalidCity"
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == true)
        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage?.contains("bad server response") == true)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testFetchWeather_DecodingError() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        mockWeatherService.shouldThrowError = true
        
        // Create a decoding error
        let decodingError = DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: [],
                debugDescription: "Invalid JSON"
            )
        )
        mockWeatherService.errorToThrow = decodingError
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "London"
        
        await viewModel.fetchWeather()
        
        #expect(mockWeatherService.fetchWeatherCalled == true)
        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test func testFetchWeather_ClearsErrorMessage() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        mockWeatherService.weatherResponse = WeatherResponse.mock()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "London"
        viewModel.errorMessage = "Previous error"
        
        await viewModel.fetchWeather()
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.weather != nil)
    }
    
    @Test func testFetchWeather_WithNilCityName() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse(
            weather: [WeatherResponse.Weather(description: "cloudy")],
            main: WeatherResponse.Main(temp: 288.15),
            name: nil // Testing nil city name
        )
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "TestCity"
        
        await viewModel.fetchWeather()
        
        #expect(viewModel.weather?.name == nil)
        #expect(viewModel.weather?.main.temp == 288.15)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Save Favorite Tests
    
    @Test func testSaveFavorite_Success() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "Tokyo"
        viewModel.saveFavorite()
        
        #expect(mockFavoritesStore.saveCalled == true)
        #expect(mockFavoritesStore.saveCalledWith == "Tokyo")
    }
    
    @Test func testSaveFavorite_TrimsWhitespace() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "  Tokyo  "
        viewModel.saveFavorite()
        
        #expect(mockFavoritesStore.saveCalled == true)
        #expect(mockFavoritesStore.saveCalledWith == "Tokyo")
    }
    
    @Test func testSaveFavorite_EmptyCity() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = ""
        viewModel.saveFavorite()
        
        #expect(mockFavoritesStore.saveCalled == false)
        #expect(mockFavoritesStore.saveCalledWith == nil)
    }
    
    @Test func testSaveFavorite_WhitespaceOnlyCity() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "   "
        viewModel.saveFavorite()
        
        #expect(mockFavoritesStore.saveCalled == false)
        #expect(mockFavoritesStore.saveCalledWith == nil)
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteWorkflow_FetchAndSave() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse.mock(
            name: "Berlin",
            temperature: 291.15, // 18°C in Kelvin
            description: "partly cloudy"
        )
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        // Set city and fetch weather
        viewModel.city = "Berlin"
        await viewModel.fetchWeather()
        
        // Verify fetch worked
        #expect(viewModel.weather?.name == "Berlin")
        #expect(viewModel.weather?.main.temp == 291.15)
        #expect(viewModel.errorMessage == nil)
        
        // Save as favorite
        viewModel.saveFavorite()
        
        // Verify save worked
        #expect(mockFavoritesStore.saveCalled == true)
        #expect(mockFavoritesStore.saveCalledWith == "Berlin")
    }
    
    @Test func testCompleteWorkflow_FetchErrorThenSuccess() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "TestCity"
        
        // First attempt - error
        mockWeatherService.shouldThrowError = true
        mockWeatherService.errorToThrow = URLError(.networkConnectionLost)
        
        await viewModel.fetchWeather()
        
        #expect(viewModel.weather == nil)
        #expect(viewModel.errorMessage != nil)
        
        // Second attempt - success
        mockWeatherService.shouldThrowError = false
        mockWeatherService.weatherResponse = WeatherResponse.mock(name: "TestCity")
        
        await viewModel.fetchWeather()
        
        #expect(viewModel.weather?.name == "TestCity")
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Weather Response Data Integrity Tests
    
    @Test func testWeatherResponse_AllFieldsPresent() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse(
            weather: [
                WeatherResponse.Weather(description: "light rain"),
                WeatherResponse.Weather(description: "overcast clouds")
            ],
            main: WeatherResponse.Main(temp: 285.5),
            name: "Moscow"
        )
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "Moscow"
        await viewModel.fetchWeather()
        
        #expect(viewModel.weather?.name == "Moscow")
        #expect(viewModel.weather?.main.temp == 285.5)
        #expect(viewModel.weather?.weather.count == 2)
        #expect(viewModel.weather?.weather.first?.description == "light rain")
    }
    
    @Test func testWeatherResponse_EmptyWeatherArray() async throws {
        let mockWeatherService = MockWeatherService()
        let mockFavoritesStore = MockFavoritesStore()
        let mockWeatherResponse = WeatherResponse(
            weather: [], // Empty weather array
            main: WeatherResponse.Main(temp: 280.0),
            name: "TestCity"
        )
        mockWeatherService.weatherResponse = mockWeatherResponse
        
        let viewModel = HomeViewModel(
            weatherService: mockWeatherService,
            favoritesStore: mockFavoritesStore
        )
        
        viewModel.city = "TestCity"
        await viewModel.fetchWeather()
        
        #expect(viewModel.weather?.weather.isEmpty == true)
        #expect(viewModel.weather?.main.temp == 280.0)
        #expect(viewModel.errorMessage == nil)
    }
}
