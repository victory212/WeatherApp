//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//


import Foundation
import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var city: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var weather: WeatherResponse?

    private let weatherService: WeatherServiceProtocol
    private let favoritesStore: FavoritesStore

    init(weatherService: WeatherServiceProtocol, favoritesStore: FavoritesStore) {
        self.weatherService = weatherService
        self.favoritesStore = favoritesStore
        if let fav = favoritesStore.load() {
            self.city = fav
        }
    }

    func fetchWeather() async {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }

        withAnimation {
            isLoading = true
        }
        errorMessage = nil
        
        do {
            let resp = try await weatherService.fetchWeather(for: trimmed)
            self.weather = resp
        } catch {
            errorMessage = error.localizedDescription
        }
        withAnimation {
            isLoading = false
        }
    }

    func saveFavorite() {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        favoritesStore.save(city: trimmed)
    }
}
