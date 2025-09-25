//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//


import Foundation

struct WeatherViewModel {
    private let response: WeatherResponse

    init(response: WeatherResponse) {
        self.response = response
    }

    var cityName: String { response.name ?? "Unknown" }
    var description: String { response.weather.first?.description.capitalized ?? "N/A" }
    var tempCelsius: String {
        let c = response.main.temp - 273.15
        return String(format: "%.1f°C", c)
    }
}