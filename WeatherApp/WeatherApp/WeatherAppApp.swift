//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    private let weatherService: WeatherServiceProtocol
    private let favoritesStore: FavoritesStore
    
    init() {
        self.weatherService = WeatherService()
        self.favoritesStore = FavoritesStore()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView {
                HomeView(
                    viewModel: HomeViewModel(
                        weatherService: weatherService,
                        favoritesStore: favoritesStore
                    )
                )
            }
        }
    }
}
