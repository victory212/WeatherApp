//
//  FavoritesStore.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import Foundation

class FavoritesStore {
    private let key = "favoriteCity"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(city: String) {
        defaults.set(city, forKey: key)
    }

    func load() -> String? {
        defaults.string(forKey: key)
    }
}
