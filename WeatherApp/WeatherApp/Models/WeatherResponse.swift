//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by Okoi Victory Ebri on 25/09/2025.
//

import Foundation

struct WeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double
    }
    struct Weather: Codable {
        let description: String
    }
    let weather: [Weather]
    let main: Main
    let name: String?
}
